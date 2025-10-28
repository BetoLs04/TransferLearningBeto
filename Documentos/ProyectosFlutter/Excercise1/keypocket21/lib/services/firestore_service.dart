import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/credential.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== CATEGORÍAS ==========

  Future<void> saveCategory(Category category) async {
    try {
      final categoryData = category.toMap();
      print('☁️ Enviando categoría a Firestore: ${category.name}');
      
      await _firestore
          .collection('users')
          .doc(category.userId)
          .collection('categories')
          .doc(category.id)
          .set(categoryData);
      print('✅ Categoría guardada en Firestore: ${category.name}');
    } catch (e) {
      print('❌ Error guardando categoría en Firestore: $e');
      rethrow;
    }
  }

  Stream<List<Category>> getCategoriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final categories = snapshot.docs
              .map((doc) => Category.fromMap(doc.data() as Map<dynamic, dynamic>))
              .toList();
          return categories;
        });
  }

  Future<List<Category>> getCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .orderBy('createdAt', descending: true)
          .get();
      
      final categories = snapshot.docs
          .map((doc) => Category.fromMap(doc.data() as Map<dynamic, dynamic>))
          .toList();
      
      print('📥 Categorías obtenidas de Firestore: ${categories.length}');
      return categories;
    } catch (e) {
      print('❌ Error obteniendo categorías de Firestore: $e');
      return [];
    }
  }

  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(categoryId)
          .delete();
      print('✅ Categoría eliminada de Firestore: $categoryId');
    } catch (e) {
      print('❌ Error eliminando categoría de Firestore: $e');
      rethrow;
    }
  }

  // ========== CREDENCIALES ==========

  Future<void> saveCredential(Credential credential) async {
    try {
      final credentialData = credential.toMap();
      print('☁️ Enviando credencial a Firestore: ${credential.title}');
      print('   - userId: ${credential.userId}');
      print('   - categoryId: ${credential.categoryId}');
      
      await _firestore
          .collection('users')
          .doc(credential.userId)
          .collection('credentials')
          .doc(credential.id)
          .set(credentialData);
      print('✅ Credencial guardada en Firestore: ${credential.title}');
    } catch (e) {
      print('❌ Error guardando credencial en Firestore: $e');
      rethrow;
    }
  }

  Stream<List<Credential>> getCredentialsStream(String userId, String categoryId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('credentials')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final credentials = snapshot.docs
              .map((doc) => Credential.fromMap(doc.data() as Map<dynamic, dynamic>))
              .toList();
          return credentials;
        });
  }

  Future<List<Credential>> getAllCredentials(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('credentials')
          .orderBy('createdAt', descending: true)
          .get();
      
      final credentials = snapshot.docs
          .map((doc) => Credential.fromMap(doc.data() as Map<dynamic, dynamic>))
          .toList();
      
      print('📥 Credenciales obtenidas de Firestore: ${credentials.length}');
      return credentials;
    } catch (e) {
      print('❌ Error obteniendo credenciales de Firestore: $e');
      return [];
    }
  }

  Future<void> deleteCredential(String credentialId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('credentials')
          .doc(credentialId)
          .delete();
      print('✅ Credencial eliminada de Firestore: $credentialId');
    } catch (e) {
      print('❌ Error eliminando credencial de Firestore: $e');
      rethrow;
    }
  }

  Future<void> syncUserData(String userId, List<Category> categories, List<Credential> credentials) async {
    try {
      print('🔄 Sincronizando datos del usuario $userId con Firestore...');
      
      // Sincronizar categorías
      for (final category in categories) {
        await saveCategory(category);
      }
      
      // Sincronizar credenciales
      for (final credential in credentials) {
        await saveCredential(credential);
      }
      
      print('✅ Sincronización completada');
    } catch (e) {
      print('❌ Error en sincronización: $e');
      rethrow;
    }
  }
}