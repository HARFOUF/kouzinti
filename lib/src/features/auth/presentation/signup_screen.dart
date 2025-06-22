import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinti/src/features/home/presentation/home_screen.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:kouzinti/src/services/auth_service.dart';

enum UserRole { client, chef }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.client;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isCheckingEmail = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if email already exists
  Future<bool> _checkEmailExists(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }

  // Email validation with existence check
  Future<String?> _validateEmail(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Check if email already exists
    setState(() {
      _isCheckingEmail = true;
    });

    try {
      final emailExists = await _checkEmailExists(value);
      if (emailExists) {
        return 'An account with this email already exists. Please use a different email or try logging in.';
      }
    } finally {
      setState(() {
        _isCheckingEmail = false;
      });
    }

    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔐 SignupScreen: Starting signup for ${_emailController.text.trim()}');
        print('🔐 SignupScreen: Selected role: ${_selectedRole.name}');
        
        // Set signup flag in AuthService to prevent document creation conflicts
        final authService = Provider.of<AuthService>(context, listen: false);
        authService.setSigningUp(true);
        
        // Create user with Firebase Auth
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        print('✅ SignupScreen: Firebase Auth user created successfully');

        // Store user data in Firestore - this is critical
        final userRole = _selectedRole == UserRole.client ? 'client' : 'chef';
        print('💾 SignupScreen: Saving user data with role: $userRole');
        
        // Create the user document with all necessary fields
        final userData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': userRole,
          'createdAt': FieldValue.serverTimestamp(),
          'profilePictureUrl': null,
        };
        
        try {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);
          print('✅ SignupScreen: User data saved to Firestore successfully');
        } catch (firestoreError) {
          print('❌ SignupScreen: Firestore error: $firestoreError');
          // Delete the Firebase Auth user if Firestore fails
          await userCredential.user!.delete();
          authService.setSigningUp(false);
          throw Exception('Failed to save user data. Please try again.');
        }

        // Try to update the user's display name in Firebase Auth
        try {
          await userCredential.user!.updateDisplayName(_nameController.text.trim());
          print('✅ SignupScreen: Display name updated successfully');
        } catch (displayNameError) {
          print('⚠️ SignupScreen: Display name update error (non-critical): $displayNameError');
          // Continue with the signup process even if display name update fails
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully as ${_selectedRole.name}!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          // Wait a bit for Firestore to be ready
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Force refresh user data
          await authService.refreshUserData();
          
          // Wait a bit more for everything to settle
          await Future.delayed(const Duration(milliseconds: 1000));
          
          print('🚀 SignupScreen: Navigating to HomeScreen');
          
          // Navigate to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        print('❌ SignupScreen: Firebase Auth error: ${e.code} - ${e.message}');
        
        // Reset signup flag on error
        final authService = Provider.of<AuthService>(context, listen: false);
        authService.setSigningUp(false);
        
        String errorMessage = 'An error occurred during sign up.';
        
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak. Please use at least 6 characters.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for that email. Please use a different email or try logging in.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          default:
            if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
              errorMessage = 'Authentication configuration error. Please try again or contact support.';
            } else {
              errorMessage = 'Sign up failed. Please try again.';
            }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        // Debug: Print the actual error
        print('❌ SignupScreen: Unexpected error: $e');
        print('❌ SignupScreen: Error type: ${e.runtimeType}');
        
        // Reset signup flag on error
        final authService = Provider.of<AuthService>(context, listen: false);
        authService.setSigningUp(false);
        
        String errorMessage = 'An unexpected error occurred.';
        
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('Failed to save user data')) {
          errorMessage = 'Failed to save user data. Please try again.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Create an Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join our community of food lovers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: _isCheckingEmail 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // Trigger validation when email changes
                      if (value.isNotEmpty) {
                        _validateEmail(value);
                      }
                    },
                    validator: (value) {
                      // Basic validation only - async validation is handled separately
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'I am a:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Client'),
                            value: UserRole.client,
                            groupValue: _selectedRole,
                            activeColor: AppColors.primary,
                            onChanged: (UserRole? value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Chef'),
                            value: UserRole.chef,
                            groupValue: _selectedRole,
                            activeColor: AppColors.primary,
                            onChanged: (UserRole? value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 