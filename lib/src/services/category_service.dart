import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinty/src/models/category_model.dart';
import 'package:kouzinty/src/models/dish_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories with error handling
  Stream<List<CategoryModel>> getAllCategories() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .handleError((error) {
          print('Error fetching categories: $error');
          throw Exception('Failed to load categories. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
                .toList();
          } catch (e) {
            print('Error parsing categories: $e');
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
          print('Error fetching dishes by category: $error');
          throw Exception('Failed to load category dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            print('Error parsing category dishes: $e');
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
          print('Error fetching popular dishes: $error');
          throw Exception('Failed to load popular dishes. Please try again.');
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => DishModel.fromFirestore(doc))
                .toList();
          } catch (e) {
            print('Error parsing popular dishes: $e');
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
      print('Error fetching category by ID: $e');
      throw Exception('Failed to load category details. Please try again.');
    }
  }

  // Initialize categories in Firebase with error handling
  Future<void> initializeCategories() async {
    try {
      // Check if categories already exist
      final existingCategories = await _firestore.collection('categories').get();
      if (existingCategories.docs.isNotEmpty) {
        print('Categories already exist, skipping initialization');
        return;
      }

      final categories = [
        {
          'name': 'Pizza',
          'icon': 'local_pizza',
          'color': '#FF6B35',
          'description': 'Delicious pizzas with various toppings',
        },
        {
          'name': 'Burgers',
          'icon': 'lunch_dining',
          'color': '#FF8C42',
          'description': 'Juicy burgers and sandwiches',
        },
        {
          'name': 'Pasta',
          'icon': 'ramen_dining',
          'color': '#FFD93D',
          'description': 'Italian pasta dishes',
        },
        {
          'name': 'Sushi',
          'icon': 'set_meal',
          'color': '#6BCF7F',
          'description': 'Fresh sushi and Japanese cuisine',
        },
        {
          'name': 'Desserts',
          'icon': 'cake',
          'color': '#FF6B9D',
          'description': 'Sweet treats and desserts',
        },
        {
          'name': 'Coffee',
          'icon': 'coffee',
          'color': '#8B4513',
          'description': 'Hot and cold coffee beverages',
        },
        {
          'name': 'Salads',
          'icon': 'rice_bowl',
          'color': '#4CAF50',
          'description': 'Fresh and healthy salads',
        },
        {
          'name': 'Seafood',
          'icon': 'dinner_dining',
          'color': '#2196F3',
          'description': 'Fresh seafood dishes',
        },
        {
          'name': 'Breakfast',
          'icon': 'breakfast_dining',
          'color': '#FF9800',
          'description': 'Morning meals and brunch',
        },
        {
          'name': 'Drinks',
          'icon': 'local_bar',
          'color': '#9C27B0',
          'description': 'Refreshing beverages and cocktails',
        },
      ];

      final batch = _firestore.batch();
      
      for (final categoryData in categories) {
        final docRef = _firestore.collection('categories').doc();
        batch.set(docRef, categoryData);
      }

      await batch.commit();
      print('Categories initialized successfully');
    } catch (e) {
      print('Error initializing categories: $e');
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
      print('Error getting category stats: $e');
      return {};
    }
  }
} 