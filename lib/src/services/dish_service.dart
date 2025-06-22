import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kouzinti/src/models/dish_model.dart';

class DishService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new dish with image URL
  Future<void> createDish({
    required String name,
    required String description,
    required double price,
    required String category,
    required String categoryId,
    required String imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create dish document first to get the ID
      final dishRef = _firestore.collection('dishes').doc();

      final dishData = {
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'category': category.trim(),
        'categoryId': categoryId,
        'chefId': user.uid,
        'imageUrl': imageUrl.trim(),
        'isAvailable': true,
        'orderCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await dishRef.set(dishData);
    } catch (e) {
      throw Exception('Failed to create dish: $e');
    }
  }

  // Update an existing dish with image URL
  Future<void> updateDish({
    required String dishId,
    required String name,
    required String description,
    required double price,
    required String category,
    required String categoryId,
    required String imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the dish belongs to the current user
      final dishDoc = await _firestore.collection('dishes').doc(dishId).get();
      if (!dishDoc.exists) {
        throw Exception('Dish not found');
      }
      
      final dishData = dishDoc.data();
      if (dishData?['chefId'] != user.uid) {
        throw Exception('You can only edit your own dishes');
      }

      final updateData = {
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'category': category.trim(),
        'categoryId': categoryId,
        'imageUrl': imageUrl.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('dishes').doc(dishId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update dish: $e');
    }
  }

  // Delete a dish and its image
  Future<void> deleteDish(String dishId, String? imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the dish belongs to the current user
      final dishDoc = await _firestore.collection('dishes').doc(dishId).get();
      if (!dishDoc.exists) {
        throw Exception('Dish not found');
      }
      
      final dishData = dishDoc.data();
      if (dishData?['chefId'] != user.uid) {
        throw Exception('You can only delete your own dishes');
      }

      await _firestore.collection('dishes').doc(dishId).delete();
    } catch (e) {
      throw Exception('Failed to delete dish: $e');
    }
  }

  // Get all dishes with error handling
  Stream<List<DishModel>> getAllDishes() {
    return _firestore
        .collection('dishes')
        .where('isAvailable', isEqualTo: true)
        // Temporarily removing orderBy to test if it's causing index issues
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to load dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            final dishes = snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
            return dishes;
          } catch (e) {
            throw Exception('Failed to parse dish data. Please try again.');
          }
        });
  }

  // Get dishes for a specific chef with error handling
  Stream<List<DishModel>> getChefDishes(String chefId) {
    return _firestore
        .collection('dishes')
        .where('chefId', isEqualTo: chefId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to load chef dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            throw Exception('Failed to parse chef dish data. Please try again.');
          }
        });
  }

  // Get a single dish by ID with error handling
  Future<DishModel?> getDishById(String dishId) async {
    try {
      final doc = await _firestore.collection('dishes').doc(dishId).get();
      if (doc.exists) {
        return DishModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load dish details. Please try again.');
    }
  }

  // Toggle dish availability with error handling
  Future<void> toggleDishAvailability(String dishId, bool isAvailable) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the dish belongs to the current user
      final dishDoc = await _firestore.collection('dishes').doc(dishId).get();
      if (!dishDoc.exists) {
        throw Exception('Dish not found');
      }
      
      final dishData = dishDoc.data();
      if (dishData?['chefId'] != user.uid) {
        throw Exception('You can only modify your own dishes');
      }

      await _firestore.collection('dishes').doc(dishId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update dish availability: $e');
    }
  }

  // Increment order count for a dish
  Future<void> incrementOrderCount(String dishId) async {
    try {
      await _firestore.collection('dishes').doc(dishId).update({
        'orderCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw error for this as it's not critical
    }
  }

  // Search dishes by name or category
  Stream<List<DishModel>> searchDishes(String query) {
    if (query.trim().isEmpty) {
      return getAllDishes();
    }

    final searchQuery = query.trim().toLowerCase();
    
    return _firestore
        .collection('dishes')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to search dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .where((dish) =>
                    dish.name.toLowerCase().contains(searchQuery) ||
                    dish.category.toLowerCase().contains(searchQuery))
                .toList();
          } catch (e) {
            throw Exception('Failed to parse search results. Please try again.');
          }
        });
  }
} 