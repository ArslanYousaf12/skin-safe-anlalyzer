import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseConfigService {
  // Singleton pattern
  static final FirebaseConfigService _instance =
      FirebaseConfigService._internal();
  factory FirebaseConfigService() => _instance;
  FirebaseConfigService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase safely with error handling
  Future<bool> initializeFirebase() async {
    try {
      debugPrint('Attempting to initialize Firebase...');
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('✅ Firebase initialized successfully!');
      return true;
    } catch (e) {
      // Check for specific error types to provide better diagnostics
      if (e.toString().contains('google-services.json')) {
        debugPrint(
            '❌ Firebase initialization failed: Missing google-services.json file');
      } else if (e.toString().contains('GoogleService-Info.plist')) {
        debugPrint(
            '❌ Firebase initialization failed: Missing GoogleService-Info.plist file');
      } else {
        debugPrint('❌ Firebase initialization failed: ${e.toString()}');
      }
      _isInitialized = false;
      return false;
    }
  }

  /// Checks if the required Firebase config files exist
  bool checkConfigFilesExist() {
    try {
      if (Platform.isAndroid) {
        // For Android, we would check for google-services.json
        // This is a simplified check - in a real app you'd need to verify the file exists in the proper location
        return File('android/app/google-services.json').existsSync();
      } else if (Platform.isIOS) {
        // For iOS, we would check for GoogleService-Info.plist
        return File('ios/Runner/GoogleService-Info.plist').existsSync();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking Firebase config files: $e');
      return false;
    }
  }

  /// Gets setup instructions for missing Firebase configuration
  String getSetupInstructions() {
    if (Platform.isAndroid) {
      return '''
To configure Firebase for Android:
1. Go to Firebase Console (https://console.firebase.google.com/)
2. Create a new project or select existing project
3. Add Android app to your Firebase project with package name from your app
4. Download the google-services.json file
5. Place it in the 'android/app/' directory
6. Rebuild your app
''';
    } else if (Platform.isIOS) {
      return '''
To configure Firebase for iOS:
1. Go to Firebase Console (https://console.firebase.google.com/)
2. Create a new project or select existing project 
3. Add iOS app to your Firebase project with bundle ID from your app
4. Download the GoogleService-Info.plist file
5. Place it in the 'ios/Runner/' directory
6. Rebuild your app
''';
    }
    return 'Please configure Firebase for your platform.';
  }
}
