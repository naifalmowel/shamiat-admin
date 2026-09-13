import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/language_provider.dart';
import 'tabs/products_tab.dart';
import 'tabs/categories_tab.dart';
import 'tabs/offers_tab.dart';
import 'login_screen.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).initDataListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final lang = Provider.of<LanguageProvider>(context);
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);
    const surfaceColor = Color(0xFFF8F9FA);

    final views = [
      const ProductsTab(),
      const CategoriesTab(),
      const OffersTab(),
      Center(child: Text(lang.getText(ar: 'إدارة المستخدمين (قريباً)', en: 'Users Management (Soon)'))),
    ];

    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(
          title: Text(
            lang.getText(ar: 'شاميات | لوحة الإدارة الذكية', en: 'Shamiat | Smart Dashboard'),
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 18),
          ),
          elevation: 0,
          actions: [
            // Language Toggle Action
            TextButton.icon(
              onPressed: () => lang.toggleLanguage(),
              icon: const Icon(Icons.language_rounded, color: accentColor, size: 20),
              label: Text(
                lang.isArabic ? 'English' : 'عربي',
                style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded),
              tooltip: lang.getText(ar: 'تسجيل الخروج', en: 'Logout'),
              onPressed: () async {
                await FirebaseService().signOut();
                if (mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: isMobile
            ? Container(
                decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentTabIndex,
                  selectedItemColor: accentColor,
                  unselectedItemColor: Colors.white70,
                  backgroundColor: primaryColor,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  onTap: (idx) => setState(() => _currentTabIndex = idx),
                  items: [
                    BottomNavigationBarItem(icon: const Icon(Icons.fastfood_rounded), label: lang.getText(ar: 'المنتجات', en: 'Products')),
                    BottomNavigationBarItem(icon: const Icon(Icons.category_rounded), label: lang.getText(ar: 'الفئات', en: 'Categories')),
                    BottomNavigationBarItem(icon: const Icon(Icons.view_carousel_rounded), label: lang.getText(ar: 'العروض', en: 'Offers')),
                    BottomNavigationBarItem(icon: const Icon(Icons.people_alt_rounded), label: lang.getText(ar: 'النظام', en: 'System')),
                  ],
                ),
              )
            : null,
        body: Row(
          children: [
            if (!isMobile)
              NavigationRail(
                selectedIndex: _currentTabIndex,
                onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
                labelType: NavigationRailLabelType.all,
                backgroundColor: primaryColor,
                useIndicator: true,
                indicatorColor: accentColor.withValues(alpha: 0.2),
                selectedIconTheme: const IconThemeData(color: accentColor, size: 30),
                unselectedIconTheme: const IconThemeData(color: Colors.white70),
                selectedLabelTextStyle: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                destinations: [
                  NavigationRailDestination(icon: const Icon(Icons.fastfood_rounded), label: Text(lang.getText(ar: 'المنتجات', en: 'Products'))),
                  NavigationRailDestination(icon: const Icon(Icons.category_rounded), label: Text(lang.getText(ar: 'الفئات', en: 'Categories'))),
                  NavigationRailDestination(icon: const Icon(Icons.view_carousel_rounded), label: Text(lang.getText(ar: 'العروض', en: 'Offers'))),
                  NavigationRailDestination(icon: const Icon(Icons.people_alt_rounded), label: Text(lang.getText(ar: 'النظام', en: 'System'))),
                ],
              ),
            const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: views[_currentTabIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
