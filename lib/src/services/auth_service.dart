import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinti/src/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSigningUp = false; // Flag to prevent document creation during signup
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _isLoading = false;
      _isSigningUp = false;
      notifyListeners();
      return;
    }

    // Prevent multiple simultaneous updates
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Add a small delay to ensure Firestore is ready
      await Future.delayed(const Duration(milliseconds: 200));
      
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Only create user document if not during signup
        if (_isSigningUp) {
          // Wait a bit more for the signup process to complete
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Try to get the user data again
          final retryDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (retryDoc.exists) {
            _currentUser = UserModel.fromMap(retryDoc.data()!, retryDoc.id);
          } else {
            _createFallbackUser(firebaseUser);
          }
        } else {
          _createFallbackUser(firebaseUser);
        }
      }
    } catch (e) {
      _createFallbackUser(firebaseUser);
    }

    _isLoading = false;
    _isSigningUp = false;
    notifyListeners();
  }

  void _createFallbackUser(User firebaseUser) {
    String firstName = 'User';
    String lastName = '';
    if (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty) {
      final parts = firebaseUser.displayName!.trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    _currentUser = UserModel(
      id: firebaseUser.uid,
      firstName: firstName,
      lastName: lastName,
      email: firebaseUser.email ?? '',
      role: 'client', // Default role for fallback
      profilePictureUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );
    
    // Try to save the user data in the background
    _saveUserDataInBackground(_currentUser!);
  }

  // Background method to save user data without blocking
  void _saveUserDataInBackground(UserModel user) {
    Future.microtask(() async {
      try {
        await createUserData(user);
      } catch (e) {
        // Silent fail for background operations
      }
    });
  }

  Future<void> createUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'role': user.role,
        'profilePictureUrl': user.profilePictureUrl,
        'phoneNumber': user.phoneNumber,
        'address': user.address,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Set signup flag to prevent document creation during signup
  void setSigningUp(bool isSigningUp) {
    _isSigningUp = isSigningUp;
  }

  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    
    await _onAuthStateChanged(user);
  }

  // Ensure user data exists in Firestore
  Future<void> ensureUserDataExists() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final userData = UserModel(
          id: user.uid,
          firstName: user.displayName?.split(' ').first ?? 'User',
          lastName: user.displayName?.split(' ').length > 1 ? user.displayName!.split(' ').sublist(1).join(' ') : '',
          email: user.email ?? '',
          role: 'client',
          profilePictureUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        
        await createUserData(userData);
        
        // Update current user
        _currentUser = userData;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently or rethrow based on requirements
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? address,
    String? profilePictureUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final updateData = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
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
      return null;
    }
  }

  // Check if email exists before signup
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
} 