# SkinSafe Analyzer

A Flutter application that helps users analyze skincare and cosmetic products for harmful ingredients. The app uses OCR technology to scan ingredient lists from product packaging, analyzes each ingredient against a safety database, and provides detailed reports on potential concerns.

## Features

- **Product Search**: Look up products by name in our database
- **Camera Scanning**: Scan product packaging using your device's camera
- **Ingredient OCR**: Extract ingredient lists from images using text recognition
- **Safety Analysis**: Each ingredient is analyzed for safety concerns
- **Detailed Reports**: Get comprehensive safety reports with ingredient breakdowns
- **History Tracking**: Keep track of previously analyzed products
- **Safe Alternatives**: Get suggestions for safer alternatives to harmful ingredients

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.3.0)
- Android Studio / VS Code with Flutter extensions
- Firebase project (for backend functionality)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/arslanyousaf12/skinsafe_analyzer.git
   cd skinsafe_analyzer
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project and follow the setup instructions
   - Download and add the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  ├── main.dart           # App entry point
  ├── models/             # Data models
  │   ├── ingredient.dart
  │   ├── product.dart
  │   └── safety_report.dart
  ├── screens/            # App screens
  │   ├── home_screen.dart
  │   ├── analysis_result_screen.dart
  │   ├── history_screen.dart
  │   ├── camera_screen.dart
  │   └── splash_screen.dart
  ├── services/           # Business logic and services
  │   ├── api_service.dart
  │   ├── firebase_service.dart
  │   ├── ingredient_analyzer_service.dart
  │   └── ocr_service.dart
  ├── utils/              # Utilities and helpers
  │   ├── constants.dart
  │   ├── theme.dart
  │   └── validators.dart
  └── widgets/            # Reusable UI components
      ├── ingredient_list_widget.dart
      ├── input_methods_widget.dart
      └── safety_score_widget.dart
```

## Technologies Used

- **Flutter**: UI framework
- **Firebase**: Authentication, Cloud Firestore, Storage
- **Google ML Kit**: Text recognition (OCR)
- **Provider**: State management

## Data Sources

The ingredient safety data is sourced from various authoritative references, including:
- Environmental Working Group (EWG)
- PubMed research papers
- FDA reports
- CosIng (European Commission database)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Environmental Working Group for their work on ingredient safety
- Flutter team for the amazing framework
- All the open-source packages used in this project
# skin-safe-anlalyzer
