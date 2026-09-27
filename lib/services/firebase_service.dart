import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../models/offer.dart';
import '../models/app_settings.dart';

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

  // --- Firestore App Settings ---
  Stream<AppSettings> getSettings() {
    return _db.collection('settings').doc('app_config').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppSettings.fromJson(snapshot.data()!);
      }
      return AppSettings(); // Default settings
    });
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _db.collection('settings').doc('app_config').set(settings.toJson(), SetOptions(merge: true));
  }

  // --- Firestore Admins ---
  Stream<List<Map<String, dynamic>>> getAdmins() {
    return _db.collection('admins').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> updateAdminProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('admins').doc(uid).update(data);
  }

  Future<void> addAdminRecord(String email, String name, String role, String password) async {
    try {
      // 1. Create User in Firebase Auth using a temporary secondary app instance
      // to avoid signing out the current admin.
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'TempApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      
      UserCredential cred = await tempAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      String uid = cred.user!.uid;

      // 2. Add record to Firestore with the REAL UID from Auth
      await _db.collection('admins').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'password': password, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Cleanup temp app
      await tempApp.delete();
    } catch (e) {
      print('Error adding admin to Auth/Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteAdmin(String uid) async {
    // Note: On client-side Firebase SDK, you CANNOT delete other users from Auth.
    // This requires Firebase Admin SDK (Node.js/Cloud Functions).
    // For now, we only delete the record from Firestore.
    await _db.collection('admins').doc(uid).delete();
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

  /// Clears only the imageUrl field for all products in Firestore.
  Future<void> clearAllProductImagesUrls() async {
    final snapshot = await _db.collection('products').get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'imageUrl': ''});
    }
    await batch.commit();
  }

  /// Clears all menu data from Firestore.
  Future<void> clearAllMenuData() async {
    final collections = ['products', 'categories', 'offers'];
    for (final col in collections) {
      final snapshot = await _db.collection(col).get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
