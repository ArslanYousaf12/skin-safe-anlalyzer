import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'input_method_event.dart';
import 'input_method_state.dart';
import '../../repositories/ocr_repository.dart';

class InputMethodBloc extends Bloc<InputMethodEvent, InputMethodState> {
  final OcrRepository ocrRepository;

  InputMethodBloc({required this.ocrRepository}) : super(InputMethodInitial()) {
    on<SearchByProductNameEvent>(_onSearchByProductName);
    on<ScanProductEvent>(_onScanProduct);
    on<ScanIngredientsEvent>(_onScanIngredients);
    on<UploadGalleryImageEvent>(_onUploadGalleryImage);
    on<ProcessIngredientImageEvent>(_onProcessIngredientImage);
  }

  void _onSearchByProductName(
    SearchByProductNameEvent event,
    Emitter<InputMethodState> emit,
  ) {
    emit(ProductNameSearched(event.productName));
  }

  void _onScanProduct(
    ScanProductEvent event,
    Emitter<InputMethodState> emit,
  ) {
    emit(ProductImageCaptured(event.imageFile));
  }

  Future<void> _onScanIngredients(
    ScanIngredientsEvent event,
    Emitter<InputMethodState> emit,
  ) async {
    emit(InputMethodLoading());
    try {
      await _processIngredientsImage(event.imageFile, emit);
    } catch (e) {
      emit(InputMethodError('Error processing ingredients: ${e.toString()}'));
    }
  }

  Future<void> _onUploadGalleryImage(
    UploadGalleryImageEvent event,
    Emitter<InputMethodState> emit,
  ) async {
    // This event just triggers UI to show options dialog,
    // The actual processing is handled by other events
    // We don't change state here
  }

  Future<void> _onProcessIngredientImage(
    ProcessIngredientImageEvent event,
    Emitter<InputMethodState> emit,
  ) async {
    emit(InputMethodLoading());
    try {
      await _processIngredientsImage(event.imageFile, emit);
    } catch (e) {
      emit(InputMethodError('Error processing ingredients: ${e.toString()}'));
    }
  }

  Future<void> _processIngredientsImage(
    File imageFile,
    Emitter<InputMethodState> emit,
  ) async {
    try {
      // Extract text from image using OCR
      final extractedText = await ocrRepository.extractTextFromImage(imageFile);

      // Extract ingredients from the text
      final ingredients =
          ocrRepository.extractIngredientsFromText(extractedText);

      if (ingredients.isNotEmpty) {
        emit(IngredientsExtracted(ingredients));
      } else {
        emit(const InputMethodError(
          'No ingredients found in the image. Try a clearer photo.',
        ));
      }
    } catch (e) {
      debugPrint('Error processing ingredients image: $e');
      emit(InputMethodError('Error processing ingredients: ${e.toString()}'));
    }
  }
}
