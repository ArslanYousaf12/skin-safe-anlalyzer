import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';

class OcrRepository {
  final OcrService _ocrService = OcrService();

  /// Extract text from image file
  Future<String> extractTextFromImage(File imageFile) async {
    return await _ocrService.extractTextFromImage(imageFile);
  }

  /// Extract text from image picked from gallery
  Future<String?> extractTextFromGalleryImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) return null;

      final imageFile = File(pickedImage.path);
      return await extractTextFromImage(imageFile);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Extract text from camera image
  Future<String?> extractTextFromCameraImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.camera);

      if (pickedImage == null) return null;

      final imageFile = File(pickedImage.path);
      return await extractTextFromImage(imageFile);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Extract ingredients from text
  List<String> extractIngredientsFromText(String text) {
    return _ocrService.extractIngredientsFromText(text);
  }
}
