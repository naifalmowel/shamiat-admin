import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/offer.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import '../services/data_seeder.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final SupabaseService _supabase = SupabaseService();

  List<MenuItem> _products = [];
  List<Category> _categories = [];
  List<Offer> _offers = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;

  List<MenuItem> get products => _products;
  List<Category> get categories => _categories;
  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Fetch products, categories and offers
  void initDataListeners() {
    _firebase.getProducts().listen((data) {
      data.sort((a, b) => a.order.compareTo(b.order));
      _products = data;
      _isInitialLoading = false;
      notifyListeners();
    });
    _firebase.getCategories().listen((data) {
      data.sort((a, b) => a.order.compareTo(b.order));
      _categories = data;
      notifyListeners();
    });
    _firebase.getOffers().listen((data) {
      data.sort((a, b) => a.order.compareTo(b.order));
      _offers = data;
      notifyListeners();
    });
  }

  // Reorder Categories
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();

    try {
      await _firebase.updateCategoriesOrder(_categories);
    } catch (e) {
      print('Error updating categories order: $e');
    }
  }

  // Reorder Products inside a Category
  Future<void> reorderProductsInList(List<MenuItem> currentList, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);
    notifyListeners();

    try {
      await _firebase.updateProductsOrder(currentList);
    } catch (e) {
      print('Error updating products order: $e');
    }
  }

  // Product Actions
  Future<void> saveProduct(MenuItem item, Uint8List? imageBytes, String? fileExtension) async {
    setLoading(true);
    try {
      String imageUrl = item.imageUrl;
      if (imageBytes != null) {
        final ext = fileExtension ?? 'jpg';
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final uploadedUrl = await _supabase.uploadImageBytes(imageBytes, fileName, 'products');
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

  // Offer Actions
  Future<void> saveOffer(Offer offer, Uint8List? imageBytes, String? fileExtension) async {
    setLoading(true);
    try {
      String imageUrl = offer.imageUrl;
      if (imageBytes != null) {
        final ext = fileExtension ?? 'jpg';
        final fileName = 'offer_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final uploadedUrl = await _supabase.uploadImageBytes(imageBytes, fileName, 'offers');
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }
      final updatedOffer = offer.copyWith(imageUrl: imageUrl);
      await _firebase.addOffer(updatedOffer);
    } finally {
      setLoading(false);
    }
  }

  Future<void> toggleOfferStatus(Offer offer) async {
    final updated = offer.copyWith(isActive: !offer.isActive);
    await _firebase.updateOffer(updated);
  }

  Future<void> deleteOffer(Offer offer) async {
    setLoading(true);
    try {
      if (offer.imageUrl.isNotEmpty) {
        await _supabase.deleteImage(offer.imageUrl);
      }
      await _firebase.deleteOffer(offer.id);
    } finally {
      setLoading(false);
    }
  }

  Future<void> reorderOffers(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _offers.removeAt(oldIndex);
    _offers.insert(newIndex, item);
    notifyListeners();

    try {
      await _firebase.updateOffersOrder(_offers);
    } catch (e) {
      print('Error updating offers order: $e');
    }
  }

  // Smart Sync Categories
  Future<void> syncCategoriesFromProducts() async {
    setLoading(true);
    try {
      final Set<String> uniqueCats = _products.map((p) => p.category).where((c) => c.isNotEmpty).toSet();
      
      for (var catId in uniqueCats) {
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
