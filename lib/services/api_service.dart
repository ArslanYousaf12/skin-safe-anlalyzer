import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  // You can replace these with actual API endpoints when available
  static const String _productSearchBaseUrl =
      'https://api.example.com/products';
  static const String _ingredientInfoBaseUrl =
      'https://api.example.com/ingredients';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Search for product by name
  Future<Map<String, dynamic>?> searchProductByName(String productName) async {
    try {
      final url = Uri.parse(
        '$_productSearchBaseUrl/search?name=${Uri.encodeComponent(productName)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        debugPrint('Error searching for product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error searching for product: $e');
      return null;
    }
  }

  // Get ingredient information
  Future<Map<String, dynamic>?> getIngredientInfo(String ingredientName) async {
    try {
      final url = Uri.parse(
        '$_ingredientInfoBaseUrl/${Uri.encodeComponent(ingredientName)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        debugPrint('Error getting ingredient info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting ingredient info: $e');
      return null;
    }
  }

  // Since actual APIs might not be available, we can add mock methods
  // that simulate API responses for demonstration purposes

  // Mock product search
  Future<Map<String, dynamic>?> mockSearchProductByName(
    String productName,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return a mock response
    return {
      'id': '12345',
      'name': productName,
      'brand': 'Example Brand',
      'category': 'skincare',
      'ingredients': [
        'Water',
        'Glycerin',
        'Sodium Lauryl Sulfate',
        'Fragrance',
        'Parabens',
        'Retinol',
        'Vitamin E',
      ],
      'imageUrl': 'https://example.com/product.jpg',
    };
  }

  // Mock ingredient info retrieval
  Future<Map<String, dynamic>?> mockGetIngredientInfo(
    String ingredientName,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Map of mock ingredient data
    final mockIngredients = {
      'sodium lauryl sulfate': {
        'name': 'Sodium Lauryl Sulfate',
        'description':
            'A cleansing agent and surfactant found in many personal care products.',
        'riskLevel': 'Caution',
        'concerns': [
          'May cause skin irritation',
          'Can be drying to skin and hair',
        ],
        'alternatives': ['Sodium Coco Sulfate', 'Coco Betaine'],
      },
      'fragrance': {
        'name': 'Fragrance',
        'description':
            'A blend of chemicals that gives products a distinctive scent.',
        'riskLevel': 'Caution',
        'concerns': ['Potential allergen', 'Can cause skin irritation'],
        'alternatives': ['Essential oils', 'Fragrance-free products'],
      },
      'parabens': {
        'name': 'Parabens',
        'description':
            'Preservatives used in cosmetics and personal care products.',
        'riskLevel': 'Unsafe',
        'concerns': [
          'Potential hormone disruption',
          'Linked to breast cancer in some studies',
        ],
        'alternatives': [
          'Phenoxyethanol',
          'Sodium benzoate',
          'Potassium sorbate',
        ],
      },
      'retinol': {
        'name': 'Retinol',
        'description': 'A vitamin A derivative used in anti-aging products.',
        'riskLevel': 'Caution',
        'concerns': [
          'Can cause irritation and dryness',
          'Increases sun sensitivity',
        ],
        'alternatives': ['Bakuchiol', 'Rosehip oil'],
      },
      'glycerin': {
        'name': 'Glycerin',
        'description': 'A humectant that draws moisture to the skin.',
        'riskLevel': 'Safe',
        'concerns': [],
        'alternatives': [],
      },
      'water': {
        'name': 'Water',
        'description': 'The most common ingredient in skincare products.',
        'riskLevel': 'Safe',
        'concerns': [],
        'alternatives': [],
      },
      'vitamin e': {
        'name': 'Vitamin E',
        'description':
            'An antioxidant that protects the skin from free radicals.',
        'riskLevel': 'Safe',
        'concerns': [],
        'alternatives': [],
      },
    };

    // Normalize ingredient name for lookup
    final normalizedName = ingredientName.toLowerCase().trim();

    // Return the mock data if found
    if (mockIngredients.containsKey(normalizedName)) {
      return mockIngredients[normalizedName];
    }

    // Check for partial matches
    for (final key in mockIngredients.keys) {
      if (key.contains(normalizedName) || normalizedName.contains(key)) {
        return mockIngredients[key];
      }
    }

    // If not found, return null
    return null;
  }
}
