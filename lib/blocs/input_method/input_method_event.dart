import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class InputMethodEvent extends Equatable {
  const InputMethodEvent();

  @override
  List<Object?> get props => [];
}

// Event when user searches by product name
class SearchByProductNameEvent extends InputMethodEvent {
  final String productName;

  const SearchByProductNameEvent(this.productName);

  @override
  List<Object> get props => [productName];
}

// Event when user scans a product (as a product photo)
class ScanProductEvent extends InputMethodEvent {
  final File imageFile;

  const ScanProductEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

// Event when user scans ingredients list
class ScanIngredientsEvent extends InputMethodEvent {
  final File imageFile;

  const ScanIngredientsEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

// Event when user uploads an image from gallery
class UploadGalleryImageEvent extends InputMethodEvent {
  const UploadGalleryImageEvent();
}

// Event to process image for ingredients extraction
class ProcessIngredientImageEvent extends InputMethodEvent {
  final File imageFile;

  const ProcessIngredientImageEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}
