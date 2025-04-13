import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class InputMethodState extends Equatable {
  const InputMethodState();

  @override
  List<Object?> get props => [];
}

class InputMethodInitial extends InputMethodState {}

class InputMethodLoading extends InputMethodState {}

class ProductNameSearched extends InputMethodState {
  final String productName;

  const ProductNameSearched(this.productName);

  @override
  List<Object> get props => [productName];
}

class ProductImageCaptured extends InputMethodState {
  final File imageFile;

  const ProductImageCaptured(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class IngredientsExtracted extends InputMethodState {
  final List<String> ingredients;

  const IngredientsExtracted(this.ingredients);

  @override
  List<Object> get props => [ingredients];
}

class InputMethodError extends InputMethodState {
  final String message;

  const InputMethodError(this.message);

  @override
  List<Object> get props => [message];
}
