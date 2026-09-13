import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/offer.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Auth ---
  Future<UserCredential?> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // --- Firestore Products ---
  Stream<List<MenuItem>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => MenuItem.fromJson(doc.data())).toList());
  }

  Future<void> addProduct(MenuItem item) async {
    await _db.collection('products').doc(item.id).set(item.toJson());
  }

  Future<void> updateProduct(MenuItem item) async {
    await _db.collection('products').doc(item.id).update(item.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // --- Firestore Categories ---
  Stream<List<Category>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());
  }

  Future<void> addCategory(Category category) async {
    await _db.collection('categories').doc(category.id).set(category.toJson());
  }

  Future<void> updateCategory(Category category) async {
    await _db.collection('categories').doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  // --- Firestore Offers ---
  Stream<List<Offer>> getOffers() {
    return _db.collection('offers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Offer.fromJson(doc.data())).toList());
  }

  Future<void> addOffer(Offer offer) async {
    await _db.collection('offers').doc(offer.id).set(offer.toJson());
  }

  Future<void> updateOffer(Offer offer) async {
    await _db.collection('offers').doc(offer.id).update(offer.toJson());
  }

  Future<void> deleteOffer(String id) async {
    await _db.collection('offers').doc(id).delete();
  }

  // --- Firestore Batch Order Updates ---
  Future<void> updateCategoriesOrder(List<Category> categories) async {
    final batch = _db.batch();
    for (int i = 0; i < categories.length; i++) {
      final docRef = _db.collection('categories').doc(categories[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future<void> updateProductsOrder(List<MenuItem> items) async {
    final batch = _db.batch();
    for (int i = 0; i < items.length; i++) {
      final docRef = _db.collection('products').doc(items[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future<void> updateOffersOrder(List<Offer> offers) async {
    final batch = _db.batch();
    for (int i = 0; i < offers.length; i++) {
      final docRef = _db.collection('offers').doc(offers[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }
}
