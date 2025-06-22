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
    print('🔄 AuthService: Auth state changed - User: ${firebaseUser?.email}');
    
    if (firebaseUser == null) {
      print('🚪 AuthService: User signed out');
      _currentUser = null;
      _isLoading = false;
      _isSigningUp = false;
      notifyListeners();
      return;
    }

    // Prevent multiple simultaneous updates
    if (_isLoading) {
      print('⚠️ AuthService: Already loading user data, skipping...');
      return;
    }

    print('👤 AuthService: User signed in - ${firebaseUser.email}');
    _isLoading = true;
    notifyListeners();

    try {
      // Add a small delay to ensure Firestore is ready
      await Future.delayed(const Duration(milliseconds: 200));
      
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        print('✅ AuthService: User data loaded successfully: ${_currentUser!.name} (Role: ${_currentUser!.role})');
      } else {
        // Only create user document if not during signup
        if (_isSigningUp) {
          print('⏳ AuthService: Signup in progress, waiting for user data to be created...');
          // Wait a bit more for the signup process to complete
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Try to get the user data again
          final retryDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (retryDoc.exists) {
            _currentUser = UserModel.fromMap(retryDoc.data()!, retryDoc.id);
            print('✅ AuthService: User data found after signup: ${_currentUser!.name} (Role: ${_currentUser!.role})');
          } else {
            print('❌ AuthService: User data still not found after signup, creating fallback');
            _createFallbackUser(firebaseUser);
          }
        } else {
          print('📝 AuthService: User document not found, creating new user data for: ${firebaseUser.email}');
          _createFallbackUser(firebaseUser);
        }
      }
    } catch (e) {
      print('❌ AuthService: Error fetching user data: $e');
      _createFallbackUser(firebaseUser);
    }

    _isLoading = false;
    _isSigningUp = false;
    print('✅ AuthService: Auth state update complete - User: ${_currentUser?.name} (Role: ${_currentUser?.role})');
    notifyListeners();
  }

  void _createFallbackUser(User firebaseUser) {
    print('🔄 AuthService: Creating fallback user data due to error');
    _currentUser = UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
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
        print('✅ AuthService: Background user data save successful');
      } catch (e) {
        print('⚠️ AuthService: Background user data save failed: $e');
      }
    });
  }

  Future<void> createUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'profilePictureUrl': user.profilePictureUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ AuthService: Error creating user data: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print('🚪 AuthService: Signing out user');
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('❌ AuthService: Error signing out: $e');
      rethrow;
    }
  }

  // Set signup flag to prevent document creation during signup
  void setSigningUp(bool isSigningUp) {
    _isSigningUp = isSigningUp;
    print('🔐 AuthService: Signup flag set to: $isSigningUp');
  }

  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('🔄 AuthService: No current user to refresh');
      return;
    }
    
    print('🔄 AuthService: Refreshing user data for ${user.email}');
    await _onAuthStateChanged(user);
  }

  // Ensure user data exists in Firestore
  Future<void> ensureUserDataExists() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ AuthService: No current user to ensure data exists');
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        print('📝 AuthService: User document doesn\'t exist, creating it');
        
        final userData = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          role: 'client',
          profilePictureUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        
        await createUserData(userData);
        print('✅ AuthService: User data created successfully');
        
        // Update current user
        _currentUser = userData;
        notifyListeners();
      } else {
        print('✅ AuthService: User document already exists');
      }
    } catch (e) {
      print('❌ AuthService: Error ensuring user data exists: $e');
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
      print('❌ AuthService: Error updating profile: $e');
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
      print('❌ AuthService: Error fetching user by ID: $e');
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
      print('❌ AuthService: Error fetching current user: $e');
      return null;
    }
  }

  // Check if email exists before signup
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('❌ AuthService: Error checking email existence: $e');
      return false;
    }
  }
} 