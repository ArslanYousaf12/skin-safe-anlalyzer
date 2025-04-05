class Validators {
  /// Validates if a string is not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validates if a string is a valid product name (at least 2 characters)
  static bool isValidProductName(String? value) {
    return value != null && value.trim().length >= 2;
  }

  /// Validates if a string is a valid email address
  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // Regular expression for email validation
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    return regExp.hasMatch(value);
  }

  /// Validates if a string is a valid image file extension
  static bool isValidImageExtension(String fileName) {
    // Check if fileName ends with a common image extension
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];

    return validExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  /// Validates if a list has at least one element
  static bool hasElements<T>(List<T>? list) {
    return list != null && list.isNotEmpty;
  }

  /// Validates if a string contains at least one ingredient name
  /// (simplistic approach, looks for text with 3+ characters)
  static bool containsIngredients(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }

    // Check if text contains "ingredients:" keyword
    if (text.toLowerCase().contains('ingredients:')) {
      return true;
    }

    // Check if text contains multiple words separated by commas
    // which is a common pattern for ingredient lists
    final commaCount = ','.allMatches(text).length;
    return commaCount >= 3; // Arbitrary threshold for possible ingredient list
  }

  /// Validates if a string looks like an ingredient list
  /// by checking for patterns common in ingredient lists
  static bool looksLikeIngredientList(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }

    // Check for common ingredient list markers
    if (text.toLowerCase().contains('ingredients:') ||
        text.toLowerCase().contains('ingredients list:')) {
      return true;
    }

    // Check for comma-separated pattern with technical terms
    final words = text.split(RegExp(r'[,.]')).map((s) => s.trim()).toList();
    if (words.length >= 4) {
      // At least 4 comma-separated terms
      // Check if some words look like chemical names (contain common suffixes)
      final chemicalSuffixes = [
        'acid',
        'oxide',
        'extract',
        'oil',
        'butter',
        'vitamin',
        'glycol',
        'alcohol',
        'sodium',
        'glycerin',
        'water',
      ];

      int technicalTerms = 0;
      for (final word in words) {
        if (word.length > 4 && // Longer than 4 chars
            chemicalSuffixes.any(
              (suffix) => word.toLowerCase().contains(suffix),
            )) {
          technicalTerms++;
        }
      }

      // If at least 25% of terms look like ingredient names
      return technicalTerms >= (words.length / 4);
    }

    return false;
  }
}
