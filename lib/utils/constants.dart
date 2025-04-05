class AppConstants {
  // App info
  static const String appName = 'SkinSafe Analyzer';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Analyze skincare and cosmetic products for harmful ingredients';

  // Routes
  static const String homeRoute = '/home';
  static const String analysisResultRoute = '/analysis-result';
  static const String historyRoute = '/history';
  static const String cameraRoute = '/camera';

  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // API constants
  static const int apiTimeoutSeconds = 30;

  // Local storage keys
  static const String searchHistoryKey = 'search_history';
  static const String userPrefsKey = 'user_preferences';

  // Safety levels
  static const String safeLevel = 'Safe';
  static const String cautionLevel = 'Caution';
  static const String unsafeLevel = 'Unsafe';
  static const String unknownLevel = 'Unknown';

  // Risk descriptions
  static const Map<String, String> riskDescriptions = {
    safeLevel: 'This ingredient is considered safe for most people.',
    cautionLevel:
        'This ingredient may cause irritation or sensitivity in some individuals.',
    unsafeLevel: 'This ingredient may be harmful and is best avoided.',
    unknownLevel: 'Not enough information available about this ingredient.',
  };

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 50.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Error messages
  static const String generalErrorMessage =
      'Something went wrong. Please try again later.';
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String noResultsMessage =
      'No results found. Please try a different search.';
  static const String cameraPermissionErrorMessage =
      'Camera permission is required to scan products.';

  // Disclaimer text
  static const String disclaimerText =
      'The analysis provided by SkinSafe Analyzer is for informational purposes only. '
      'Always consult a dermatologist or healthcare professional for personalized advice.';
}
