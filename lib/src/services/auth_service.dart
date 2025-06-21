import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinty/src/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // If user document doesn't exist, try to create it with basic info
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          role: 'client', // Default role
          profilePictureUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        
        // Try to save the user data to Firestore (but don't fail if it doesn't work)
        try {
          await createUserData(_currentUser!);
        } catch (e) {
          debugPrint('Warning: Could not save user data to Firestore: $e');
          // Continue with the user data we have
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      // Create a basic user model if there's an error (Firestore not available)
      _currentUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        role: 'client',
        profilePictureUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
      
      debugPrint('Created fallback user data for: ${_currentUser!.name}');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'profilePictureUrl': user.profilePictureUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user data: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _onAuthStateChanged(user);
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
    String? address,
    String? profilePictureUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final updateData = <String, dynamic>{
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }
      if (address != null) {
        updateData['address'] = address;
      }
      if (profilePictureUrl != null) {
        updateData['profilePictureUrl'] = profilePictureUrl;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      // Refresh user data to reflect changes
      await refreshUserData();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return null;
    }
  }
} 