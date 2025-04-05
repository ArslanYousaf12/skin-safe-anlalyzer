import 'product.dart';
import 'ingredient.dart';

class SafetyReport {
  final String id;
  final Product product;
  final String overallRating; // "Safe", "Caution", or "Unsafe"
  final int safeIngredientsCount;
  final int cautionIngredientsCount;
  final int unsafeIngredientsCount;
  final String summaryText;
  final DateTime createdAt;

  const SafetyReport({
    required this.id,
    required this.product,
    required this.overallRating,
    required this.safeIngredientsCount,
    required this.cautionIngredientsCount,
    required this.unsafeIngredientsCount,
    required this.summaryText,
    required this.createdAt,
  });

  // Factory constructor that calculates values from a product
  factory SafetyReport.fromProduct({
    required Product product,
    required String id,
  }) {
    // Calculate ingredient counts by safety level
    final safeCount = product.ingredients.where((i) => i.isSafe).length;
    final cautionCount =
        product.ingredients.where((i) => i.requiresCaution).length;
    final unsafeCount = product.ingredients.where((i) => i.isUnsafe).length;

    // Generate summary text based on findings
    String summary = '';
    if (unsafeCount > 0) {
      summary =
          'This product contains $unsafeCount potentially harmful ingredients that may be unsafe for use.';
    } else if (cautionCount > 0) {
      summary =
          'This product contains $cautionCount ingredients that require caution. May cause irritation for sensitive skin.';
    } else if (safeCount > 0) {
      summary =
          'This product appears to contain safe ingredients. No major concerns detected.';
    } else {
      summary =
          'Unable to determine product safety due to insufficient ingredient data.';
    }

    return SafetyReport(
      id: id,
      product: product,
      overallRating: product.safetyScore,
      safeIngredientsCount: safeCount,
      cautionIngredientsCount: cautionCount,
      unsafeIngredientsCount: unsafeCount,
      summaryText: summary,
      createdAt: DateTime.now(),
    );
  }

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'overallRating': overallRating,
      'safeIngredientsCount': safeIngredientsCount,
      'cautionIngredientsCount': cautionIngredientsCount,
      'unsafeIngredientsCount': unsafeIngredientsCount,
      'summaryText': summaryText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from a map
  factory SafetyReport.fromMap(Map<String, dynamic> map) {
    return SafetyReport(
      id: map['id'] as String? ?? '',
      product: Product.fromMap(map['product'] as Map<String, dynamic>),
      overallRating: map['overallRating'] as String? ?? 'Unknown',
      safeIngredientsCount: map['safeIngredientsCount'] as int? ?? 0,
      cautionIngredientsCount: map['cautionIngredientsCount'] as int? ?? 0,
      unsafeIngredientsCount: map['unsafeIngredientsCount'] as int? ?? 0,
      summaryText: map['summaryText'] as String? ?? '',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'] as String)
              : DateTime.now(),
    );
  }

  // Calculate overall safety percentage (higher is safer)
  double get safetyPercentage {
    final total =
        safeIngredientsCount + cautionIngredientsCount + unsafeIngredientsCount;
    if (total == 0) return 0;

    // Weight: Safe = 1, Caution = 0.5, Unsafe = 0
    final weightedSum = safeIngredientsCount + (cautionIngredientsCount * 0.5);
    return (weightedSum / total) * 100;
  }
}
