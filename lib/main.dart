import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Requires google-services.json)
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyC0OTLvYlB7xo1VUUFqcvmvdvn3DsScT4s",
          authDomain: "shamiat.firebaseapp.com",
          projectId: "shamiat",
          storageBucket: "shamiat.firebasestorage.app",
          messagingSenderId: "944141429395",
          appId: "1:944141429395:web:034f453403a0ed9c47fb66",
          measurementId: "G-VY27F0N9VG"
      ),
    );
  } catch (e) {
    print('Firebase Init Error: $e');
  }

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AdminProvider())],
      child: const ShamiatAdminApp(),
    ),
  );
}

class ShamiatAdminApp extends StatelessWidget {
  const ShamiatAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);
    const lightBg = Color(0xFFFAF9F6);

    return MaterialApp(
      title: 'شاميات أدمن الذكية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: lightBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
