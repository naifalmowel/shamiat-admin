import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/offer.dart';
import '../models/app_settings.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import '../services/data_seeder.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final SupabaseService _supabase = SupabaseService();

  List<MenuItem> _products = [];
  List<Category> _categories = [];
  List<Offer> _offers = [];
  List<Map<String, dynamic>> _admins = [];
  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  bool _isInitialLoading = true;

  List<MenuItem> get products => _products;
  List<Category> get categories => _categories;
  List<Offer> get offers => _offers;
  List<Map<String, dynamic>> get admins => _admins;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

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
    _firebase.getSettings().listen((data) {
      _settings = data;
      notifyListeners();
    });
    _firebase.getAdmins().listen((data) {
      _admins = data;
      notifyListeners();
    });
  }

  // --- Product Actions ---
  
  Future<void> saveProduct(MenuItem item, Uint8List? imageBytes, String? fileExtension) async {
    setLoading(true);
    try {
      String oldImageUrl = '';
      try {
        final existing = _products.firstWhere((p) => p.id == item.id);
        oldImageUrl = existing.imageUrl;
      } catch (_) {}

      String newImageUrl = item.imageUrl;
      bool uploadSuccess = false;
      
      if (imageBytes != null) {
        final ext = fileExtension ?? 'jpg';
        final uploadedUrl = await _supabase.uploadImageWithHash(imageBytes, ext, 'products');
        if (uploadedUrl != null) {
          newImageUrl = uploadedUrl;
          uploadSuccess = true;
        }
      } else {
        uploadSuccess = true; 
      }
      
      if (uploadSuccess && oldImageUrl.isNotEmpty && oldImageUrl != newImageUrl) {
        await _supabase.deleteImageByUrl(oldImageUrl);
      }

      final updatedItem = item.copyWith(imageUrl: newImageUrl);
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
        await _supabase.deleteImageByUrl(item.imageUrl);
      }
      await _firebase.deleteProduct(item.id);
    } finally {
      setLoading(false);
    }
  }

  // --- Category Actions ---

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

  // --- Offer Actions ---

  Future<void> saveOffer(Offer offer, Uint8List? imageBytes, String? fileExtension) async {
    setLoading(true);
    try {
      String oldImageUrl = '';
      try {
        final existing = _offers.firstWhere((o) => o.id == offer.id);
        oldImageUrl = existing.imageUrl;
      } catch (_) {}

      String newImageUrl = offer.imageUrl;
      bool uploadSuccess = false;

      if (imageBytes != null) {
        final ext = fileExtension ?? 'jpg';
        final uploadedUrl = await _supabase.uploadImageWithHash(imageBytes, ext, 'offers');
        if (uploadedUrl != null) {
          newImageUrl = uploadedUrl;
          uploadSuccess = true;
        }
      } else {
        uploadSuccess = true;
      }

      if (uploadSuccess && oldImageUrl.isNotEmpty && oldImageUrl != newImageUrl) {
        await _supabase.deleteImageByUrl(oldImageUrl);
      }

      final updatedOffer = offer.copyWith(imageUrl: newImageUrl);
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
        await _supabase.deleteImageByUrl(offer.imageUrl);
      }
      await _firebase.deleteOffer(offer.id);
    } finally {
      setLoading(false);
    }
  }

  // --- Settings Actions ---

  Future<void> updateSettings(AppSettings newSettings) async {
    setLoading(true);
    try {
      await _firebase.updateSettings(newSettings);
    } finally {
      setLoading(false);
    }
  }

  // --- Admin Actions ---

  Future<void> saveAdmin(String email, String name, String role, String password) async {
    setLoading(true);
    try {
      await _firebase.addAdminRecord(email, name, role, password);
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateAdminProfile(String uid, {String? name, String? role, String? password}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (role != null) updates['role'] = role;
    if (password != null) updates['password'] = password;
    
    if (updates.isNotEmpty) {
      await _firebase.updateAdminProfile(uid, updates);
    }
  }

  Future<void> deleteAdmin(String uid) async {
    setLoading(true);
    try {
      await _firebase.deleteAdmin(uid);
    } finally {
      setLoading(false);
    }
  }

  // --- Utility Actions ---

  Future<List<String>> getStorageGallery(String folder) async {
    return await _supabase.listImages(folder);
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();
    await _firebase.updateCategoriesOrder(_categories);
  }

  Future<void> reorderProductsInList(List<MenuItem> currentList, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);
    notifyListeners();
    await _firebase.updateProductsOrder(currentList);
  }

  Future<void> reorderOffers(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _offers.removeAt(oldIndex);
    _offers.insert(newIndex, item);
    notifyListeners();
    await _firebase.updateOffersOrder(_offers);
  }

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

  // --- Bulk & Reset Actions ---

  Future<void> bulkUploadToFolder(List<XFile> files, String folder) async {
    setLoading(true);
    try {
      for (var file in files) {
        final bytes = await file.readAsBytes();
        final ext = file.name.split('.').last;
        await _supabase.uploadImageWithHash(bytes, ext, folder);
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> clearProductImagesOnly() async {
    setLoading(true);
    try {
      // 1. Delete images from Supabase storage (only products folder)
      await _supabase.deleteAllFilesInFolder('products');
      // 2. Clear imageUrl field in Firestore (only products collection)
      await _firebase.clearAllProductImagesUrls();
    } finally {
      setLoading(false);
    }
  }

  Future<void> resetAllSystemData() async {
    setLoading(true);
    try {
      // 1. Clear Firestore
      await _firebase.clearAllMenuData();
      // 2. Clear Storage
      await _supabase.deleteAllStorageFiles();
    } finally {
      setLoading(false);
    }
  }
}
