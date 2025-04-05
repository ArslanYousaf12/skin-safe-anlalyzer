import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ingredient.dart';

class IngredientAnalyzerService {
  // Singleton pattern
  static final IngredientAnalyzerService _instance =
      IngredientAnalyzerService._internal();

  factory IngredientAnalyzerService() {
    return _instance;
  }

  IngredientAnalyzerService._internal();

  // Map of ingredient names to their safety data
  late Map<String, dynamic> _ingredientsDatabase;
  bool _isInitialized = false;

  // Initialize the ingredient database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load ingredient database from JSON file
      final jsonString = await rootBundle.loadString(
        'assets/data/ingredients_database.json',
      );
      _ingredientsDatabase = json.decode(jsonString);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading ingredients database: $e');
      // Create empty database if loading fails
      _ingredientsDatabase = {};
    }
  }

  // Analyze a single ingredient
  Future<Ingredient> analyzeIngredient(String ingredientName) async {
    await _ensureInitialized();

    // Normalize the ingredient name for comparison
    final normalizedName = _normalizeIngredientName(ingredientName);

    // Search for exact or partial matches
    final matches = _findIngredientMatches(normalizedName);

    // If no matches found, return a default ingredient with unknown safety
    if (matches.isEmpty) {
      return Ingredient(
        name: ingredientName,
        description: 'No information available about this ingredient.',
        riskLevel: 'Unknown',
      );
    }

    // Use the first (best) match
    final bestMatch = matches.first;
    return Ingredient(
      name: ingredientName,
      description: bestMatch['description'] ?? 'No description available.',
      riskLevel: bestMatch['riskLevel'] ?? 'Unknown',
      concerns: List<String>.from(bestMatch['concerns'] ?? []),
      alternatives: List<String>.from(bestMatch['alternatives'] ?? []),
    );
  }

  // Analyze multiple ingredients
  Future<List<Ingredient>> analyzeIngredients(
    List<String> ingredientNames,
  ) async {
    final List<Ingredient> results = [];

    for (final name in ingredientNames) {
      if (name.isNotEmpty) {
        final ingredient = await analyzeIngredient(name);
        results.add(ingredient);
      }
    }

    return results;
  }

  // Find potential matches for an ingredient in the database
  List<Map<String, dynamic>> _findIngredientMatches(String normalizedName) {
    final List<Map<String, dynamic>> matches = [];

    // Look for exact match first
    for (final key in _ingredientsDatabase.keys) {
      final normalizedKey = _normalizeIngredientName(key);

      if (normalizedKey == normalizedName) {
        // Exact match
        matches.add(_ingredientsDatabase[key]);
        return matches; // Return immediately for exact match
      }
    }

    // Then look for partial matches (ingredient name contains the search term)
    for (final key in _ingredientsDatabase.keys) {
      final normalizedKey = _normalizeIngredientName(key);

      if (normalizedKey.contains(normalizedName) ||
          normalizedName.contains(normalizedKey)) {
        matches.add(_ingredientsDatabase[key]);
      }
    }

    return matches;
  }

  // Normalize ingredient name for better matching
  String _normalizeIngredientName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove special characters
  }

  // Make sure database is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
