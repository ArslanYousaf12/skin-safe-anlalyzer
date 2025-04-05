import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final textRecognizer = TextRecognizer();

  // Singleton pattern
  static final OcrService _instance = OcrService._internal();

  factory OcrService() {
    return _instance;
  }

  OcrService._internal();

  /// Extract text from image file
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error extracting text from image: $e');
      return '';
    }
  }

  /// Extract text from image picked from gallery or camera
  Future<String> extractTextFromPickedImage(ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);

      if (pickedImage == null) return '';

      final imageFile = File(pickedImage.path);
      return await extractTextFromImage(imageFile);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return '';
    }
  }

  /// Extract ingredients from text by filtering and cleaning up
  List<String> extractIngredientsFromText(String text) {
    if (text.isEmpty) return [];

    // Look for ingredients lists which often follow patterns like:
    // - "Ingredients:" or "INGREDIENTS:" followed by a list
    // - Lists separated by commas or dots
    // - All caps text sections that contain chemical names

    // Convert text to lowercase for easier searching
    final lowerText = text.toLowerCase();

    // Try to find the ingredients section
    int startIndex = lowerText.indexOf('ingredients:');
    if (startIndex == -1) {
      startIndex = lowerText.indexOf('ingredients');
    }

    // If we found an ingredients section
    if (startIndex != -1) {
      // Extract text after "ingredients:" to the end of text or next section
      final ingredientsSection = text.substring(startIndex);

      // Split by common separators in ingredients lists
      final ingredients =
          ingredientsSection
              .replaceAll('Ingredients:', '')
              .replaceAll('INGREDIENTS:', '')
              .replaceAll('ingredients:', '')
              .split(RegExp(r'[,.]'))
              .map((ingredient) => ingredient.trim())
              .where((ingredient) => ingredient.isNotEmpty)
              .toList();

      return ingredients;
    }

    // If no ingredients section found, return empty list
    return [];
  }

  /// Dispose resources
  void dispose() {
    textRecognizer.close();
  }
}
