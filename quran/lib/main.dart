import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/create_account_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file with error handling for web/Windows
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const AuthWrapper(),
    );
  }
}

// Auth wrapper to handle persistence
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFd4af37)),
            ),
          );
        }

        // If user is logged in, show HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise show CreateAccountScreen
        return const CreateAccountScreen();
      },
    );
  }
}
