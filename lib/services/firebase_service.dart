import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../models/safety_report.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // UUIDs for ID generation
  final _uuid = Uuid();

  // Auth methods
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isUserSignedIn => currentUser != null;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Save a product analysis to user history
  Future<void> saveProductAnalysis(SafetyReport report) async {
    try {
      // Ensure user is authenticated
      if (!isUserSignedIn) {
        await signInAnonymously();
      }

      // Get user ID for storing data
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Save to user's history collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(report.id)
          .set(report.toMap());
    } catch (e) {
      debugPrint('Error saving product analysis: $e');
      rethrow;
    }
  }

  // Get user's product analysis history
  Future<List<SafetyReport>> getProductAnalysisHistory() async {
    try {
      // Ensure user is authenticated
      if (!isUserSignedIn) {
        await signInAnonymously();
      }

      // Get user ID
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get history sorted by creation date (newest first)
      final querySnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('history')
              .orderBy('createdAt', descending: true)
              .get();

      // Convert to SafetyReport objects
      return querySnapshot.docs
          .map((doc) => SafetyReport.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting product analysis history: $e');
      return [];
    }
  }

  // Upload product image to Firebase Storage
  Future<String> uploadProductImage(File imageFile) async {
    try {
      // Generate unique file name
      final fileName = '${_uuid.v4()}.jpg';

      // Create reference to file location
      final ref = _storage.ref().child('product_images/$fileName');

      // Upload file
      await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading product image: $e');
      return '';
    }
  }

  // Generate a new unique ID
  String generateId() => _uuid.v4();
}
