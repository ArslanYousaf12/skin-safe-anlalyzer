import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/ingredient_analyzer_service.dart';
import 'services/ocr_service.dart';
import 'services/firebase_service.dart';
import 'services/firebase_config_service.dart';
import 'repositories/ocr_repository.dart';
import 'blocs/input_method/input_method.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with the proper options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    // Continue without Firebase
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Repositories
        RepositoryProvider<OcrRepository>(
          create: (_) => OcrRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoCs
          BlocProvider<InputMethodBloc>(
            create: (context) => InputMethodBloc(
              ocrRepository: context.read<OcrRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme
              .lightTheme, // Can be replaced with a dark theme in future
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
