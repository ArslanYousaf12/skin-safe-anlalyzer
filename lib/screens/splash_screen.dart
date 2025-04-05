import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/ingredient_analyzer_service.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _initialized = false;
  String _statusMessage = 'Initializing services...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Add a delay before initializing services to give UI time to render
    Timer(const Duration(milliseconds: 500), () {
      _initializeServices();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeServices() async {
    try {
      // Update status message
      _updateStatus('Checking Firebase status...');

      // Try Firebase initialization but don't block if it fails
      try {
        if (!Provider.of<FirebaseService>(context, listen: false)
            .isUserSignedIn) {
          await Provider.of<FirebaseService>(context, listen: false)
              .signInAnonymously()
              .timeout(const Duration(seconds: 5));
          _updateStatus('Firebase initialized successfully');
        }
      } catch (e) {
        debugPrint('Firebase initialization error: $e');
        _updateStatus('Continuing without Firebase...');
      }

      // Initialize ingredient database
      _updateStatus('Loading ingredient database...');
      try {
        await Provider.of<IngredientAnalyzerService>(context, listen: false)
            .initialize()
            .timeout(const Duration(seconds: 5));
        _updateStatus('Ingredient database loaded');
      } catch (e) {
        debugPrint('Ingredient database error: $e');
        _updateStatus('Error loading database, will try to continue');
      }

      // Mark as initialized even if there were some errors
      setState(() {
        _initialized = true;
        _statusMessage = 'Ready to analyze your products!';
      });

      // Navigate to home screen after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    } catch (e) {
      debugPrint('Splash screen initialization error: $e');
      _updateStatus('Error during initialization');

      // Even if there's an error, try to proceed to the home screen
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
    debugPrint(message);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and app name
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.health_and_safety,
                                size: 80,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // App name
                            Text(
                              AppConstants.appName,
                              style: AppTheme.headingStyle.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tagline
                            Text(
                              'Know what goes on your skin',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Loading indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
