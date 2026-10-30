import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/annonce_provider.dart';
import '../widgets/annonce_card.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les annonces dès l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnonceProvider>().chargerAnnonces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/auth'),
          ),
        ],
      ),
      body: Consumer<AnnonceProvider>(
        builder: (context, provider, _) {
          if (provider.chargement) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.annonces.isEmpty) {
            return const Center(child: Text('Aucune annonce pour le moment'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.chargerAnnonces(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.annonces.length,
              itemBuilder: (context, index) {
                final annonce = provider.annonces[index];
                return AnnonceCard(
                  annonce: annonce,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: annonce.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/publier'),
        child: const Icon(Icons.add),
      ),
    );
  }
}