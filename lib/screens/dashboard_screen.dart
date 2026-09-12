import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'tabs/products_tab.dart';
import 'tabs/categories_tab.dart';
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
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);
    const surfaceColor = Color(0xFFF8F9FA);

    final views = [
      const ProductsTab(),
      const CategoriesTab(),
      const Center(child: Text('إدارة الكاروسيل (قريباً)')),
      const Center(child: Text('إدارة المستخدمين (قريباً)')),
    ];

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'شاميات | لوحة الإدارة الذكية',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            tooltip: 'تسجيل الخروج',
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
              decoration: BoxDecoration(
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
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.fastfood_rounded), label: 'المنتجات'),
                  BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'الفئات'),
                  BottomNavigationBarItem(icon: Icon(Icons.view_carousel_rounded), label: 'العروض'),
                  BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'النظام'),
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
              indicatorColor: accentColor.withOpacity(0.2),
              selectedIconTheme: const IconThemeData(color: accentColor, size: 30),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedLabelTextStyle: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.fastfood_rounded), label: Text('المنتجات')),
                NavigationRailDestination(icon: Icon(Icons.category_rounded), label: Text('الفئات')),
                NavigationRailDestination(icon: Icon(Icons.view_carousel_rounded), label: Text('العروض')),
                NavigationRailDestination(icon: Icon(Icons.people_alt_rounded), label: Text('النظام')),
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
    );
  }
}
