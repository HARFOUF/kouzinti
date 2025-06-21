import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinty/src/services/category_service.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryService _categoryService = CategoryService();

  Future<void> generateSampleData() async {
    // First, initialize categories
    await _categoryService.initializeCategories();
    
    // Get categories for dish assignment
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final categories = categoriesSnapshot.docs;
    
    // Generate 5 chefs
    final chefs = [
      {
        'name': 'Chef Maria Rodriguez',
        'email': 'maria.rodriguez@example.com',
        'role': 'chef',
        'phoneNumber': '+1-555-0101',
        'address': '123 Main St, New York, NY',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Chef James Chen',
        'email': 'james.chen@example.com',
        'role': 'chef',
        'phoneNumber': '+1-555-0102',
        'address': '456 Oak Ave, Los Angeles, CA',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Chef Sarah Johnson',
        'email': 'sarah.johnson@example.com',
        'role': 'chef',
        'phoneNumber': '+1-555-0103',
        'address': '789 Pine Rd, Chicago, IL',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Chef Antonio Martinez',
        'email': 'antonio.martinez@example.com',
        'role': 'chef',
        'phoneNumber': '+1-555-0104',
        'address': '321 Elm St, Miami, FL',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      },
      {
        'name': 'Chef Emily Davis',
        'email': 'emily.davis@example.com',
        'role': 'chef',
        'phoneNumber': '+1-555-0105',
        'address': '654 Maple Dr, Seattle, WA',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      },
    ];

    // Create chefs in Firestore
    final chefIds = <String>[];
    for (final chefData in chefs) {
      final chefRef = _firestore.collection('users').doc();
      await chefRef.set({
        ...chefData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      chefIds.add(chefRef.id);
    }

    // Generate dishes for each chef
    final dishes = [
      // Chef Maria Rodriguez - Italian/Spanish Cuisine
      {
        'name': 'Margherita Pizza',
        'description': 'Classic Italian pizza with fresh mozzarella, tomato sauce, and basil',
        'price': 18.99,
        'imageUrl': 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400&h=300&fit=crop',
        'category': 'Pizza',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pizza').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Paella Valenciana',
        'description': 'Traditional Spanish rice dish with seafood, chicken, and saffron',
        'price': 24.99,
        'imageUrl': 'https://images.unsplash.com/photo-1515443961218-a51367888e4b?w=400&h=300&fit=crop',
        'category': 'Seafood',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Seafood').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 32,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tiramisu',
        'description': 'Italian dessert with coffee-flavored mascarpone cream',
        'price': 12.99,
        'imageUrl': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&h=300&fit=crop',
        'category': 'Desserts',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Desserts').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 28,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Spaghetti Carbonara',
        'description': 'Roman pasta with eggs, cheese, pancetta, and black pepper',
        'price': 16.99,
        'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop',
        'category': 'Pasta',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pasta').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 38,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Espresso',
        'description': 'Strong Italian coffee served in a small cup',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&h=300&fit=crop',
        'category': 'Coffee',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Coffee').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 67,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef James Chen - Asian Fusion
      {
        'name': 'Dragon Roll Sushi',
        'description': 'California roll topped with eel, avocado, and spicy mayo',
        'price': 22.99,
        'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop',
        'category': 'Sushi',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Sushi').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 52,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Kung Pao Chicken',
        'description': 'Spicy Chinese dish with chicken, peanuts, and vegetables',
        'price': 19.99,
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        'category': 'Lunch',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Burgers').id, // Using Burgers category
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 41,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Green Tea Ice Cream',
        'description': 'Creamy matcha ice cream with a hint of sweetness',
        'price': 8.99,
        'imageUrl': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
        'category': 'Desserts',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Desserts').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 35,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Bubble Tea',
        'description': 'Sweet tea with chewy tapioca pearls',
        'price': 6.99,
        'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 73,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Ramen Bowl',
        'description': 'Japanese noodle soup with rich broth and toppings',
        'price': 21.99,
        'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop',
        'category': 'Pasta',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pasta').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 48,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Sarah Johnson - American Classics
      {
        'name': 'Classic Cheeseburger',
        'description': 'Juicy beef patty with cheese, lettuce, tomato, and special sauce',
        'price': 15.99,
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
        'category': 'Burgers',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Burgers').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 89,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Caesar Salad',
        'description': 'Fresh romaine lettuce with parmesan, croutons, and caesar dressing',
        'price': 13.99,
        'imageUrl': 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop',
        'category': 'Salads',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Salads').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 56,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Apple Pie',
        'description': 'Traditional American pie with cinnamon-spiced apples',
        'price': 11.99,
        'imageUrl': 'https://images.unsplash.com/photo-1535920527002-b35e3f412d0f?w=400&h=300&fit=crop',
        'category': 'Desserts',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Desserts').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 42,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Pancakes',
        'description': 'Fluffy buttermilk pancakes served with maple syrup',
        'price': 12.99,
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        'category': 'Breakfast',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Breakfast').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 64,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Iced Coffee',
        'description': 'Cold brewed coffee served over ice with cream',
        'price': 4.99,
        'imageUrl': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&h=300&fit=crop',
        'category': 'Coffee',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Coffee').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 78,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Antonio Martinez - Mexican/Latin
      {
        'name': 'Tacos al Pastor',
        'description': 'Marinated pork tacos with pineapple and cilantro',
        'price': 14.99,
        'imageUrl': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&h=300&fit=crop',
        'category': 'Burgers', // Using Burgers category for tacos
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Burgers').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 71,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Guacamole',
        'description': 'Fresh avocado dip with lime, cilantro, and spices',
        'price': 8.99,
        'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
        'category': 'Salads',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Salads').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Churros',
        'description': 'Crispy fried dough pastries with cinnamon sugar',
        'price': 9.99,
        'imageUrl': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=300&fit=crop',
        'category': 'Desserts',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Desserts').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 38,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Margarita',
        'description': 'Classic tequila cocktail with lime and triple sec',
        'price': 12.99,
        'imageUrl': 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 82,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Huevos Rancheros',
        'description': 'Mexican breakfast with eggs, tortillas, and ranchero sauce',
        'price': 16.99,
        'imageUrl': 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&h=300&fit=crop',
        'category': 'Breakfast',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Breakfast').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 53,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Emily Davis - Pacific Northwest
      {
        'name': 'Salmon Teriyaki',
        'description': 'Grilled salmon with sweet teriyaki glaze and vegetables',
        'price': 26.99,
        'imageUrl': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop',
        'category': 'Seafood',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Seafood').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 47,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Quinoa Bowl',
        'description': 'Healthy bowl with quinoa, roasted vegetables, and tahini dressing',
        'price': 17.99,
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        'category': 'Salads',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Salads').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 39,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Berry Cheesecake',
        'description': 'Creamy cheesecake topped with fresh mixed berries',
        'price': 13.99,
        'imageUrl': 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400&h=300&fit=crop',
        'category': 'Desserts',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Desserts').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 31,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Avocado Toast',
        'description': 'Sourdough toast with smashed avocado, sea salt, and red pepper flakes',
        'price': 11.99,
        'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&h=300&fit=crop',
        'category': 'Breakfast',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Breakfast').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 67,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Cold Brew Coffee',
        'description': 'Smooth cold brewed coffee with a hint of chocolate',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&h=300&fit=crop',
        'category': 'Coffee',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Coffee').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 91,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Create dishes in Firestore
    final batch = _firestore.batch();
    for (final dishData in dishes) {
      final dishRef = _firestore.collection('dishes').doc();
      batch.set(dishRef, dishData);
    }

    await batch.commit();
    print('Sample data generated successfully!');
  }
} 