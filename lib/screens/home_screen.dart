import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/input_methods_widget.dart';
import '../services/ocr_service.dart';
import '../services/api_service.dart';
import '../services/ingredient_analyzer_service.dart';
import '../services/firebase_service.dart';
import '../models/ingredient.dart';
import '../models/product.dart';
import '../models/safety_report.dart';
import '../blocs/input_method/input_method.dart';
import 'analysis_result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About',
          ),
        ],
      ),
      body: BlocListener<InputMethodBloc, InputMethodState>(
        listener: (context, state) {
          if (state is ProductNameSearched) {
            _handleProductNameSearch(state.productName);
          } else if (state is IngredientsExtracted) {
            _handleIngredientsExtracted(state.ingredients);
          } else if (state is ProductImageCaptured) {
            _handleProductImageCaptured(state.imageFile);
          }
        },
        child: _isLoading
            ? _buildLoadingIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const InputMethodsWidget(),
                    _buildDisclaimerSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: const BoxDecoration(color: AppTheme.primaryColor),
      child: Column(
        children: [
          const Icon(Icons.health_and_safety, size: 64, color: Colors.white),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Analyze Your Products',
            style: AppTheme.headingStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Find out if your skincare or cosmetic products contain harmful ingredients',
            style: AppTheme.captionStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.defaultPadding),
          Text('Analyzing product...'),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  'Disclaimer',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(AppConstants.disclaimerText, style: AppTheme.captionStyle),
        ],
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConstants.appName,
        applicationVersion: AppConstants.appVersion,
        applicationIcon: const Icon(
          Icons.health_and_safety,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Text(AppConstants.appDescription, style: AppTheme.bodyStyle),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'This app is designed to help users make informed decisions about skincare and cosmetic products by analyzing ingredients for potential harmful effects.',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'Data provided by Environmental Working Group (EWG) and other trusted sources.',
          ),
        ],
      ),
    );
  }

  // Handle product search by name
  Future<void> _handleProductNameSearch(String productName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use API to search for product
      final apiService = ApiService();
      final productData = await apiService.mockSearchProductByName(productName);

      if (productData == null) {
        _showErrorMessage('Product not found. Try a different search term.');
        return;
      }

      // Extract ingredients from product data
      final ingredientNames = List<String>.from(
        productData['ingredients'] ?? [],
      );
      await _analyzeIngredients(
        ingredientNames,
        productName: productData['name'] ?? productName,
        brand: productData['brand'] ?? 'Unknown Brand',
        category: productData['category'] ?? 'skincare',
        imageUrl: productData['imageUrl'] ?? '',
      );
    } catch (e) {
      _showErrorMessage('Error searching for product: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle ingredients from OCR
  Future<void> _handleIngredientsExtracted(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _showErrorMessage('No ingredients detected. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _analyzeIngredients(
        ingredients,
        productName: 'Unknown Product',
        brand: 'Unknown Brand',
        category: 'unknown',
      );
    } catch (e) {
      _showErrorMessage('Error analyzing ingredients: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle product image capture
  Future<void> _handleProductImageCaptured(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract text from product image using OCR
      final ocrService = OcrService();
      final extractedText = await ocrService.extractTextFromImage(imageFile);

      // Try to extract product name from text (basic implementation)
      String productName = 'Unknown Product';
      if (extractedText.isNotEmpty) {
        // Simple heuristic: first line might be product name
        final lines = extractedText.split('\n');
        if (lines.isNotEmpty && lines[0].length > 2) {
          productName = lines[0].trim();
        }
      }

      // Extract ingredients from text
      final ingredients = ocrService.extractIngredientsFromText(extractedText);

      if (ingredients.isEmpty) {
        _showErrorMessage(
          'No ingredients detected in the image. Try taking a clearer photo of the ingredients list.',
        );
        return;
      }

      await _analyzeIngredients(
        ingredients,
        productName: productName,
        brand: 'Unknown Brand',
        category: 'unknown',
      );
    } catch (e) {
      _showErrorMessage('Error processing product image: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Analyze ingredients and navigate to results
  Future<void> _analyzeIngredients(
    List<String> ingredientNames, {
    required String productName,
    required String brand,
    required String category,
    String imageUrl = '',
  }) async {
    try {
      // Analyze each ingredient
      final analyzerService = IngredientAnalyzerService();
      final List<Ingredient> analyzedIngredients =
          await analyzerService.analyzeIngredients(ingredientNames);

      // Create product model
      final product = Product(
        id: FirebaseService().generateId(),
        name: productName,
        brand: brand,
        category: category,
        ingredients: analyzedIngredients,
        imageUrl: imageUrl,
        analyzedDate: DateTime.now(),
      );

      // Generate safety report
      final report = SafetyReport.fromProduct(
        product: product,
        id: FirebaseService().generateId(),
      );

      // Save to history
      await FirebaseService().saveProductAnalysis(report);

      // Navigate to results screen
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(report: report),
        ),
      );
    } catch (e) {
      _showErrorMessage('Error analyzing ingredients: ${e.toString()}');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
