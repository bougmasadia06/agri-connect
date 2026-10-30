import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/annonce_provider.dart';
import '../providers/prix_provider.dart';
import '../providers/auth_provider.dart';
import '../models/produit.dart';
import '../models/region.dart';

class PublierAnnonceScreen extends StatefulWidget {
  const PublierAnnonceScreen({super.key});

  @override
  State<PublierAnnonceScreen> createState() => _PublierAnnonceScreenState();
}

class _PublierAnnonceScreenState extends State<PublierAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();

  // Pour le MVP: listes fixes. Plus tard, tu les chargeras depuis
  // GET /api/produits et GET /api/regions
  final List<Produit> _produits = [
    Produit(id: '1', nom: 'Mil', unite: 'kg'),
    Produit(id: '2', nom: 'Tomates', unite: 'kg'),
    Produit(id: '3', nom: 'Maïs', unite: 'kg'),
  ];
  final List<Region> _regions = [
    Region(id: '1', nom: 'Koudougou'),
    Region(id: '2', nom: 'Ouagadougou'),
    Region(id: '3', nom: 'Bobo-Dioulasso'),
  ];

  Produit? _produitChoisi;
  Region? _regionChoisie;
  bool _publication = false;

  void _onSelectionChangee() {
    if (_produitChoisi != null && _regionChoisie != null) {
      context.read<PrixProvider>().chargerPrix(_produitChoisi!.id, _regionChoisie!.id);
    }
  }

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;
    if (_produitChoisi == null || _regionChoisie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un produit et une région')),
      );
      return;
    }

    setState(() => _publication = true);

    final auth = context.read<AuthProvider>();
    if (auth.token == null) {
      setState(() => _publication = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour publier une annonce')),
      );
      return;
    }

    try {
      await context.read<AnnonceProvider>().publier({
        'produit': {
          'id': _produitChoisi!.id,
          'nom': _produitChoisi!.nom,
          'unite': _produitChoisi!.unite,
        },
        'region': {
          'id': _regionChoisie!.id,
          'nom': _regionChoisie!.nom,
        },
        'quantite_disponible': double.parse(_quantiteController.text),
        'prix_propose': double.parse(_prixController.text),
      }, auth.token!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce publiée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _publication = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une annonce')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Produit>(
                initialValue: _produitChoisi,
                decoration: const InputDecoration(labelText: 'Produit'),
                items: _produits
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.nom)))
                    .toList(),
                onChanged: (valeur) {
                  setState(() => _produitChoisi = valeur);
                  _onSelectionChangee();
                },
                validator: (valeur) => valeur == null ? 'Choisis un produit' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantiteController,
                      decoration: const InputDecoration(labelText: 'Quantité (kg)'),
                      keyboardType: TextInputType.number,
                      validator: (valeur) =>
                          (valeur == null || valeur.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prixController,
                      decoration: const InputDecoration(labelText: 'Prix (FCFA/kg)'),
                      keyboardType: TextInputType.number,
                      validator: (valeur) =>
                          (valeur == null || valeur.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Consumer<PrixProvider>(
                builder: (context, prixProvider, _) {
                  if (_produitChoisi == null || _regionChoisie == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prixProvider.prixActuel != null
                                ? 'Prix moyen du marché à ${_regionChoisie!.nom}: '
                                    '${prixProvider.prixActuel!.prixMoyen.toStringAsFixed(0)} FCFA/kg'
                                : 'Pas encore de données de prix pour cette combinaison',
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Region>(
                initialValue: _regionChoisie,
                decoration: const InputDecoration(labelText: 'Région'),
                items: _regions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.nom)))
                    .toList(),
                onChanged: (valeur) {
                  setState(() => _regionChoisie = valeur);
                  _onSelectionChangee();
                },
                validator: (valeur) => valeur == null ? 'Choisis une région' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _publication ? null : _publier,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _publication
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Publier l\'annonce'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}