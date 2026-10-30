import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();

  bool _modeInscription = false;
  String _type = 'agriculteur';

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      if (_modeInscription) {
        await auth.register({
          'nom': _nomController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'mot_de_passe': _motDePasseController.text,
          'type': _type,
        });
      } else {
        await auth.login(
          _telephoneController.text.trim(),
          _motDePasseController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chargement = context.watch<AuthProvider>().chargement;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeInscription ? 'Créer un compte' : 'Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_modeInscription) ...[
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone (avec indicatif)',
                  hintText: 'ex: 22670123456',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _motDePasseController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? '4 caractères minimum' : null,
              ),
              if (_modeInscription) ...[
                const SizedBox(height: 18),
                const Text('Je suis :'),
                RadioListTile<String>(
                  title: const Text('Agriculteur (je vends)'),
                  value: 'agriculteur',
                  groupValue: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
                RadioListTile<String>(
                  title: const Text('Acheteur (je cherche)'),
                  value: 'acheteur',
                  groupValue: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: chargement ? null : _valider,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: chargement
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_modeInscription ? 'S\'inscrire' : 'Se connecter'),
              ),
              TextButton(
                onPressed: () => setState(() => _modeInscription = !_modeInscription),
                child: Text(
                  _modeInscription
                      ? 'J\'ai déjà un compte'
                      : 'Pas de compte ? Créer un compte',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }
}