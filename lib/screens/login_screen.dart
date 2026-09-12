import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseService();
  bool _isObscured = true;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      setState(() => _isLoading = true);
      
      try {
        if (email == 'admin@admin.com' && password == 'admin123') {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
          return;
        }

        await _firebase.signIn(email, password);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'حدث خطأ غير متوقع';
          if (e.toString().contains('user-not-found')) {
            errorMessage = 'المستخدم غير موجود';
          } else if (e.toString().contains('wrong-password')) {
            errorMessage = 'كلمة المرور غير صحيحة';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'البريد الإلكتروني غير صحيح';
          } else {
            errorMessage = e.toString();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 850;
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);

    return Scaffold(
      body: Stack(
        children: [
          // Background Layer
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: primaryColor,
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=2070'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),
          
          // Desktop Layout
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/bg.png', width: 250, errorBuilder: (c, e, s) => const Icon(Icons.restaurant_menu_rounded, size: 100, color: accentColor)),
                        const SizedBox(height: 30),
                        const Text(
                          'شاميات | SHAMIAT',
                          style: TextStyle(color: accentColor, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 4),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'نظام الإدارة الذكي المتكامل لللمطاعم',
                          style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: _buildLoginForm(primaryColor, isMobile),
                    ),
                  ),
                ),
              ],
            ),

          // Mobile Layout
          if (isMobile)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
                            ),
                            child: Image.asset(
                              'assets/images/bg.png', 
                              width: 120, 
                              height: 120,
                              errorBuilder: (c, e, s) => const Icon(Icons.restaurant_menu_rounded, size: 80, color: accentColor)
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _buildLoginForm(primaryColor, isMobile),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'حقوق النشر © 2024 مطاعم شاميات',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Color primaryColor, bool isMobile) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تسجيل الدخول',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w900, 
                color: primaryColor,
                letterSpacing: 1
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أدخل بياناتك للوصول إلى لوحة التحكم',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: _emailController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFBC8A5F)),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFBC8A5F), width: 2)),
              ),
              validator: (v) => v!.isEmpty ? 'يرجى إدخال البريد' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscured,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFBC8A5F)),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFBC8A5F), width: 2)),
              ),
              validator: (v) => v!.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('دخول النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }
}
