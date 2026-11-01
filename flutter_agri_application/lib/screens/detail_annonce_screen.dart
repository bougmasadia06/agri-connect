import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/annonce_provider.dart';
import '../providers/prix_provider.dart';
import '../providers/auth_provider.dart';
import '../models/annonce.dart';
import '../services/annonce_api.dart';
import '../services/upload_api.dart';

class DetailAnnonceScreen extends StatefulWidget {
  final String annonceId;

  const DetailAnnonceScreen({super.key, required this.annonceId});

  @override
  State<DetailAnnonceScreen> createState() => _DetailAnnonceScreenState();
}

class _DetailAnnonceScreenState extends State<DetailAnnonceScreen> {
  final AnnonceApi _annonceApi = AnnonceApi();
  Annonce? _annonce;
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerDetail();
  }

  Future<void> _chargerDetail() async {
    final annonce = await _annonceApi.getAnnonceDetail(widget.annonceId);
    if (!mounted) return;
    setState(() {
      _annonce = annonce;
      _chargement = false;
    });

    context.read<PrixProvider>().chargerPrix(annonce.produit.id, annonce.region.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final annonce = _annonce!;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'annonce')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: annonce.image != null && annonce.image!.isNotEmpty
                    ? Image.network(
                        '${UploadApi.serveurUrl}${annonce.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${annonce.produit.nom} - ${annonce.quantiteDisponible.toStringAsFixed(0)} ${annonce.produit.unite}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      annonce.region.nom,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prix proposé', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${annonce.prixPropose.toStringAsFixed(0)} FCFA/${annonce.produit.unite}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Consumer<PrixProvider>(
                    builder: (context, prixProvider, _) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix moyen marché', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              prixProvider.prixActuel != null
                                  ? '${prixProvider.prixActuel!.prixMoyen.toStringAsFixed(0)} FCFA/${annonce.produit.unite}'
                                  : '—',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  child: Text(annonce.utilisateur.nom.substring(0, 2).toUpperCase()),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(annonce.utilisateur.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Text('Agriculteur', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _contacter(context, annonce),
                icon: const Icon(Icons.chat),
                label: const Text('Contacter via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contacter(BuildContext context, Annonce annonce) async {
    final auth = context.read<AuthProvider>();
    final annonceProvider = context.read<AnnonceProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final numero = annonce.utilisateur.telephone.replaceAll(RegExp(r'[^0-9]'), '');

    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre annonce de ${annonce.produit.nom} '
      '(${annonce.quantiteDisponible.toStringAsFixed(0)} ${annonce.produit.unite}) sur AgriConnect.',
    );

    final url = Uri.parse('https://wa.me/$numero?text=$message');

    // WhatsApp d'abord : le navigateur bloque l'ouverture d'un nouvel onglet
    // si elle arrive après une attente réseau.
    final ouvert = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ouvert) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
      );
    }

    // Enregistrer le contact seulement pour un compte acheteur
    if (auth.token != null && auth.utilisateur?.type == 'acheteur') {
      try {
        await annonceProvider.contacter(annonce.id, auth.token!);
      } catch (_) {
        // Un échec d'enregistrement ne doit pas bloquer le contact
      }
    }
  }
}