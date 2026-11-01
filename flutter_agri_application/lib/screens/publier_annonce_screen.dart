import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/annonce_provider.dart';
import '../providers/prix_provider.dart';
import '../providers/auth_provider.dart';
import '../models/produit.dart';
import '../models/region.dart';
import '../services/referentiel_api.dart';
import '../services/upload_api.dart';

class PublierAnnonceScreen extends StatefulWidget {
  const PublierAnnonceScreen({super.key});

  @override
  State<PublierAnnonceScreen> createState() => _PublierAnnonceScreenState();
}

class _PublierAnnonceScreenState extends State<PublierAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final ReferentielApi _referentielApi = ReferentielApi();

  List<Produit> _produits = [];
  List<Region> _regions = [];
  bool _chargementListes = true;
  String? _erreurListes;

  Produit? _produitChoisi;
  Region? _regionChoisie;
  bool _publication = false;

  XFile? _photo;
  Uint8List? _apercu;

  @override
  void initState() {
    super.initState();
    _chargerListes();
  }

  Future<void> _chargerListes() async {
    try {
      final produits = await _referentielApi.getProduits();
      final regions = await _referentielApi.getRegions();
      if (!mounted) return;
      setState(() {
        _produits = produits;
        _regions = regions;
        _chargementListes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erreurListes = 'Impossible de charger les produits et régions';
        _chargementListes = false;
      });
    }
  }

  Future<void> _choisirPhoto() async {
    final fichier = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (fichier == null) return;
    final octets = await fichier.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photo = fichier;
      _apercu = octets;
    });
  }

  void _onSelectionChangee() {
    if (_produitChoisi != null && _regionChoisie != null) {
      context.read<PrixProvider>().chargerPrix(_produitChoisi!.id, _regionChoisie!.id);
    }
  }

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour publier une annonce')),
      );
      return;
    }

    setState(() => _publication = true);

    try {
      String? urlImage;
      if (_photo != null) {
        urlImage = await UploadApi().envoyerImage(_photo!, auth.token!);
      }

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
        if (urlImage != null) 'image': urlImage,
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
    if (_chargementListes) {
      return Scaffold(
        appBar: AppBar(title: const Text('Publier une annonce')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_erreurListes != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Publier une annonce')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_erreurListes!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chargementListes = true;
                    _erreurListes = null;
                  });
                  _chargerListes();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Publier une annonce')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _choisirPhoto,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _apercu != null
                      ? Image.memory(_apercu!, fit: BoxFit.cover, width: double.infinity)
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                              SizedBox(height: 6),
                              Text('Ajouter une photo (optionnel)',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _publication
                    ? const SizedBox(
                        height: 18,
                        width: 18,
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