import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get userStream => _auth.authStateChanges();

  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid, 
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return _userFromFirebase(result.user);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<AppUser?> registerWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return _userFromFirebase(result.user);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  AppUser? getCurrentUser() {
    final user = _auth.currentUser;
    return _userFromFirebase(user);
  }
}