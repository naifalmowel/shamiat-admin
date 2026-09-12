import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/category.dart';

class DataSeeder {
  static Future<void> seedMenuFromJson() async {
    try {
      final String response = await rootBundle.loadString('lib/menu.json');
      final List<dynamic> data = json.decode(response);
      
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final WriteBatch batch = db.batch();

      Set<String> categoryIds = {};

      for (var item in data) {
        final MenuItem product = MenuItem.fromJson(item);
        final DocumentReference docRef = db.collection('products').doc(product.id);
        batch.set(docRef, product.toJson());
        
        if (product.category.isNotEmpty) {
          categoryIds.add(product.category);
        }
      }

      // Automatically create basic categories if they don't exist
      for (var catId in categoryIds) {
        final DocumentReference catRef = db.collection('categories').doc(catId);
        // We use set with merge: true to not overwrite if exists, 
        // but here we just want to ensure they exist for the UI
        batch.set(catRef, {
          'id': catId,
          'nameAr': _getCatNameAr(catId),
          'nameEn': catId.replaceAll('_', ' ').toUpperCase(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print('Successfully seeded ${data.length} products and ${categoryIds.length} categories to Firestore');
    } catch (e) {
      print('Error seeding data: $e');
      rethrow;
    }
  }

  static String _getCatNameAr(String id) {
    switch (id) {
      case 'shawarma': return 'شاورما';
      case 'sandwich': return 'ساندويتشات';
      case 'fries': return 'بطاطس ومقبلات';
      case 'meals': return 'وجبات';
      case 'chicken_meals': return 'وجبات دجاج';
      case 'appetizers': return 'مقبلات';
      case 'beverages': return 'مشروبات';
      case 'desserts': return 'حلويات';
      default: return id;
    }
  }
}
