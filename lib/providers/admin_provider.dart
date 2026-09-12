import 'dart:io';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import '../services/data_seeder.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final SupabaseService _supabase = SupabaseService();

  List<MenuItem> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<MenuItem> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Fetch products and categories
  void initDataListeners() {
    _firebase.getProducts().listen((data) {
      _products = data;
      notifyListeners();
    });
    _firebase.getCategories().listen((data) {
      _categories = data;
      notifyListeners();
    });
  }

  // Product Actions
  Future<void> saveProduct(MenuItem item, File? imageFile) async {
    setLoading(true);
    try {
      String imageUrl = item.imageUrl;
      if (imageFile != null) {
        final uploadedUrl = await _supabase.uploadImage(imageFile, 'products');
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }
      
      final updatedItem = item.copyWith(imageUrl: imageUrl);
      await _firebase.addProduct(updatedItem);
    } finally {
      setLoading(false);
    }
  }

  Future<void> toggleAvailability(MenuItem item) async {
    final updated = item.copyWith(isAvailable: !item.isAvailable);
    await _firebase.updateProduct(updated);
  }

  Future<void> deleteProduct(MenuItem item) async {
    setLoading(true);
    try {
      if (item.imageUrl.isNotEmpty) {
        await _supabase.deleteImage(item.imageUrl);
      }
      await _firebase.deleteProduct(item.id);
    } finally {
      setLoading(false);
    }
  }

  // Category Actions
  Future<void> saveCategory(Category category) async {
    setLoading(true);
    try {
      await _firebase.addCategory(category);
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteCategory(String id) async {
    setLoading(true);
    try {
      await _firebase.deleteCategory(id);
    } finally {
      setLoading(false);
    }
  }

  // Smart Sync Categories
  Future<void> syncCategoriesFromProducts() async {
    setLoading(true);
    try {
      final Set<String> uniqueCats = _products.map((p) => p.category).where((c) => c.isNotEmpty).toSet();
      
      for (var catId in uniqueCats) {
        // Check if category already exists
        if (!_categories.any((c) => c.id == catId)) {
          final newCat = Category(
            id: catId,
            nameAr: _getLabelAr(catId),
            nameEn: catId.replaceAll('_', ' ').toUpperCase(),
          );
          await _firebase.addCategory(newCat);
        }
      }
    } finally {
      setLoading(false);
    }
  }

  String _getLabelAr(String id) {
    switch (id) {
      case 'shawarma': return 'شاورما';
      case 'sandwich': return 'ساندويتشات';
      case 'fries': return 'مقبلات وبطاطس';
      case 'meals': return 'وجبات';
      case 'chicken_meals': return 'وجبات دجاج';
      case 'appetizers': return 'مقبلات';
      case 'beverages': return 'مشروبات';
      case 'desserts': return 'حلويات';
      default: return id;
    }
  }

  // Seeder Action
  Future<bool> runSeeder() async {
    setLoading(true);
    try {
      await DataSeeder.seedMenuFromJson();
      return true;
    } catch (e) {
      print('Seeder Provider Error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
