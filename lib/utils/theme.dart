import 'package:flutter/material.dart';

class AppTheme {
  // App colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Safety color indicators
  static const Color safeColor = Color(0xFF4CAF50); // Green
  static const Color cautionColor = Color(0xFFFF9800); // Orange
  static const Color unsafeColor = Color(0xFFF44336); // Red
  static const Color unknownColor = Color(0xFF9E9E9E); // Grey

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
    fontFamily: 'Poppins',
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
    fontFamily: 'Poppins',
  );

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primaryColor,
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: primaryColor),
    ),
  );

  // Input decoration
  static InputDecoration inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: textSecondaryColor),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Get color based on safety level
  static Color getSafetyColor(String safetyLevel) {
    switch (safetyLevel.toLowerCase()) {
      case 'safe':
        return safeColor;
      case 'caution':
        return cautionColor;
      case 'unsafe':
        return unsafeColor;
      default:
        return unknownColor;
    }
  }

  // Light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge: headingStyle,
      displayMedium: subheadingStyle,
      bodyLarge: bodyStyle,
      bodyMedium: captionStyle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
