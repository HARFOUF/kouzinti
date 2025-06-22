import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinti/src/models/category_model.dart';
import 'package:kouzinti/src/models/dish_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories with error handling
  Stream<List<CategoryModel>> getAllCategories() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to load categories. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
                .toList();
          } catch (e) {
            throw Exception('Failed to parse category data. Please try again.');
          }
        });
  }

  // Get dishes by category with error handling
  Stream<List<DishModel>> getDishesByCategory(String categoryId) {
    return _firestore
        .collection('dishes')
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to load category dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            throw Exception('Failed to parse category dish data. Please try again.');
          }
        });
  }

  // Get popular dishes (dishes with most orders) with error handling
  Stream<List<DishModel>> getPopularDishes({int limit = 10}) {
    return _firestore
        .collection('dishes')
        .where('isAvailable', isEqualTo: true)
        .orderBy('orderCount', descending: true)
        .limit(limit)
        .snapshots()
        .handleError((error) {
          throw Exception('Failed to load popular dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            throw Exception('Failed to parse popular dish data. Please try again.');
          }
        });
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        return CategoryModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load category details. Please try again.');
    }
  }

  // Initialize categories in Firebase with error handling
  Future<void> initializeCategories() async {
    try {
      // Check if categories already exist
      final existingCategories = await _firestore.collection('categories').get();
      if (existingCategories.docs.isNotEmpty) {
        return;
      }

      final categories = [
        {
          'name': 'Traditional',
          'icon': 'restaurant',
          'color': '#8B4513',
          'description': 'Traditional Algerian dishes and classics',
        },
        {
          'name': 'Pastries',
          'icon': 'bakery_dining',
          'color': '#FF6B9D',
          'description': 'Sweet Algerian pastries and desserts',
        },
        {
          'name': 'Drinks',
          'icon': 'local_bar',
          'color': '#00BCD4',
          'description': 'Traditional Algerian drinks and beverages',
        },
      ];

      final batch = _firestore.batch();
      
      for (final categoryData in categories) {
        final docRef = _firestore.collection('categories').doc();
        batch.set(docRef, categoryData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to initialize categories: $e');
    }
  }

  // Get category statistics
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final dishesSnapshot = await _firestore
          .collection('dishes')
          .where('isAvailable', isEqualTo: true)
          .get();

      final Map<String, int> categoryCounts = {};
      
      for (final doc in dishesSnapshot.docs) {
        final categoryId = doc.data()['categoryId'] as String?;
        if (categoryId != null) {
          categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
        }
      }

      return categoryCounts;
    } catch (e) {
      return {};
    }
  }
} 