import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/ingredient_analyzer_service.dart';
import 'services/ocr_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue without Firebase for development/testing
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IngredientAnalyzerService>(
          create: (_) => IngredientAnalyzerService(),
        ),
        Provider<OcrService>(
          create: (_) => OcrService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme:
            AppTheme.lightTheme, // Can be replaced with a dark theme in future
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
