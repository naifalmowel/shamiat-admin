import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'providers/language_provider.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';

void main() async {
  // 1. Start engine immediately
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Fast Initialization with timeout to prevent hanging
  try {
    await Future.wait([
      Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyC0OTLvYlB7xo1VUUFqcvmvdvn3DsScT4s",
            authDomain: "shamiat.firebaseapp.com",
            projectId: "shamiat",
            storageBucket: "shamiat.firebasestorage.app",
            messagingSenderId: "944141429395",
            appId: "1:944141429395:web:034f453403a0ed9c47fb66",
            measurementId: "G-VY27F0N9VG"
        ),
      ),
      SupabaseService.initialize(),
    ]).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Initialization handled or timed out: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
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

    final lang = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: lang.getText(ar: 'شاميات أدمن الذكية', en: 'Shamiat Smart Admin'),
      debugShowCheckedModeBanner: false,
      locale: lang.currentLocale,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
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
      ),
      home: const LoginScreen(),
    );
  }
}
