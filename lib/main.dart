import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kouzinti/firebase_options.dart';
import 'package:kouzinti/src/constants/app_theme.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:kouzinti/src/features/auth/presentation/login_screen.dart';
import 'package:kouzinti/src/features/home/presentation/home_screen.dart';
import 'package:kouzinti/src/services/auth_service.dart';
import 'package:kouzinti/src/services/cart_service.dart';
import 'package:kouzinti/src/widgets/dynamic_logo.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CartService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kouzinti',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        print('🏠 AuthWrapper: isLoading=${authService.isLoading}, isAuthenticated=${authService.isAuthenticated}');
        print('🏠 AuthWrapper: currentUser=${authService.currentUser?.name}');
        
        if (authService.isLoading) {
          print('🏠 AuthWrapper: Showing splash screen');
          return const SplashScreen();
        }
        
        if (authService.isAuthenticated) {
          print('🏠 AuthWrapper: User authenticated, showing HomeScreen');
          return const HomeScreen();
        }
        
        print('🏠 AuthWrapper: User not authenticated, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const DynamicLogo(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                errorWidget: Icon(
                  Icons.restaurant,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'Kouzinti',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Delicious Food Delivered',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
} 