import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/annonce_provider.dart';
import 'providers/prix_provider.dart';
import 'screens/accueil_screen.dart';
import 'screens/detail_annonce_screen.dart';
import 'screens/publier_annonce_screen.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnonceProvider()),
        ChangeNotifierProvider(create: (_) => PrixProvider()),
      ],
      child: const MonApp(),
    ),
  );
}

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Agriculteurs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const AccueilScreen());
          case '/detail':
            final annonceId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => DetailAnnonceScreen(annonceId: annonceId),
            );
          case '/publier':
            return MaterialPageRoute(builder: (_) => const PublierAnnonceScreen());
          case '/auth':
            return MaterialPageRoute(builder: (_) => const AuthScreen());
          default:
            return MaterialPageRoute(builder: (_) => const AccueilScreen());
        }
      },
    );
  }
}