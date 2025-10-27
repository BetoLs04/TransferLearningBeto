import 'package:hive/hive.dart';
import '../models/category.dart';
import '../models/credential.dart';

class LocalStorage {
  static late Box _categoriesBox;
  static late Box _credentialsBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      try {
        _categoriesBox = await Hive.openBox('categories');
        _credentialsBox = await Hive.openBox('credentials');
        _isInitialized = true;
        print('✅ Hive inicializado correctamente');
      } catch (e) {
        print('❌ Error inicializando Hive: $e');
        rethrow;
      }
    }
  }

  // Categories CRUD
  static Future<void> insertCategory(Category category) async {
    await init();
    final userCategories = await getCategories(category.userId);
    userCategories.add(category);
    await _categoriesBox.put(category.userId, _serializeCategories(userCategories));
  }

  static Future<List<Category>> getCategories(String userId) async {
    await init();
    final List<dynamic> categoriesData = _categoriesBox.get(userId, defaultValue: []);
    return _deserializeCategories(categoriesData);
  }

  static Future<void> updateCategory(Category category) async {
    await init();
    final userCategories = await getCategories(category.userId);
    final index = userCategories.indexWhere((cat) => cat.id == category.id);
    if (index != -1) {
      userCategories[index] = category;
      await _categoriesBox.put(category.userId, _serializeCategories(userCategories));
    }
  }

  static Future<void> deleteCategory(String categoryId, String userId) async {
    await init();
    final userCategories = await getCategories(userId);
    userCategories.removeWhere((cat) => cat.id == categoryId);
    await _categoriesBox.put(userId, _serializeCategories(userCategories));
    
    final userCredentials = await getCredentialsByCategory(categoryId, userId);
    for (final credential in userCredentials) {
      await deleteCredential(credential.id, userId);
    }
  }

  // Credentials CRUD
  static Future<void> insertCredential(Credential credential) async {
    await init();
    final userCredentials = await getAllCredentials(credential.userId);
    userCredentials.add(credential);
    await _credentialsBox.put(credential.userId, _serializeCredentials(userCredentials));
  }

  static Future<List<Credential>> getCredentialsByCategory(String categoryId, String userId) async {
    await init();
    final allCredentials = await getAllCredentials(userId);
    return allCredentials.where((cred) => cred.categoryId == categoryId).toList();
  }

  static Future<List<Credential>> getAllCredentials(String userId) async {
    await init();
    final List<dynamic> credentialsData = _credentialsBox.get(userId, defaultValue: []);
    return _deserializeCredentials(credentialsData);
  }

  static Future<void> updateCredential(Credential credential) async {
    await init();
    final userCredentials = await getAllCredentials(credential.userId);
    final index = userCredentials.indexWhere((cred) => cred.id == credential.id);
    if (index != -1) {
      userCredentials[index] = credential;
      await _credentialsBox.put(credential.userId, _serializeCredentials(userCredentials));
    }
  }

  static Future<void> deleteCredential(String credentialId, String userId) async {
    await init();
    final userCredentials = await getAllCredentials(userId);
    userCredentials.removeWhere((cred) => cred.id == credentialId);
    await _credentialsBox.put(userId, _serializeCredentials(userCredentials));
  }

  static Future<void> clearUserData(String userId) async {
    await init();
    await _categoriesBox.delete(userId);
    await _credentialsBox.delete(userId);
  }

  // Métodos de serialización/deserialización
  static List<Map<String, dynamic>> _serializeCategories(List<Category> categories) {
    return categories.map((category) => category.toMap()).toList();
  }

  static List<Category> _deserializeCategories(List<dynamic> data) {
    return data.map((item) => Category.fromMap(item)).toList();
  }

  static List<Map<String, dynamic>> _serializeCredentials(List<Credential> credentials) {
    return credentials.map((credential) => credential.toMap()).toList();
  }

  static List<Credential> _deserializeCredentials(List<dynamic> data) {
    return data.map((item) => Credential.fromMap(item)).toList();
  }

  // Generar IDs únicos
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}