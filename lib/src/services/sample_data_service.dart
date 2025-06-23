import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinti/src/services/category_service.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryService _categoryService = CategoryService();

  Future<void> generateSampleData() async {
    // First, initialize categories with Algerian categories
    await _categoryService.initializeCategories();
    
    // Get categories for dish assignment
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final categories = categoriesSnapshot.docs;
    
    // Generate 5 Algerian chefs
    final chefs = [
      {
        'firstName': 'Karim',
        'lastName': 'Messaoudi',
        'email': 'karim.messaoudi@example.com',
        'role': 'chef',
        'phoneNumber': '+213-555-0104',
        'address': '321 Boulevard de la République, Annaba, Algérie',
        'profilePictureUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      },
      {
        'firstName': 'Leila',
        'lastName': 'Hamidi',
        'email': 'leila.hamidi@example.com',
        'role': 'chef',
        'phoneNumber': '+213-555-0105',
        'address': '654 Rue des Martyrs, Tlemcen, Algérie',
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

    // Generate traditional Algerian dishes
    final dishes = [
      // Chef Fatima Benali - Traditional Algerian Cuisine
      {
        'name': 'Couscous Royal',
        'description': 'Traditional Algerian couscous with lamb, chicken, and vegetables in rich broth',
        'price': 1200.0, // 1200 DZD
        'imageUrl': 'https://images.unsplash.com/photo-1515443961218-a51367888e4b?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 45,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tajine Djedj',
        'description': 'Algerian chicken tagine with preserved lemons and olives',
        'price': 850.0,
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 32,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Chorba Frik',
        'description': 'Traditional Algerian soup with cracked wheat and meat',
        'price': 450.0,
        'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 38,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Baklava',
        'description': 'Sweet pastry with layers of phyllo dough, nuts, and honey syrup',
        'price': 300.0,
        'imageUrl': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 28,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mint Tea',
        'description': 'Traditional Algerian mint tea served with pine nuts',
        'price': 150.0,
        'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[0],
        'isAvailable': true,
        'orderCount': 67,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Ahmed Boudiaf - Traditional & Drinks
      {
        'name': 'Couscous aux Fruits de Mer',
        'description': 'Seafood couscous with fresh fish, shrimp, and mussels',
        'price': 1400.0,
        'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 52,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tajine de Poisson',
        'description': 'Fish tagine with tomatoes, peppers, and aromatic spices',
        'price': 950.0,
        'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 41,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Makroud',
        'description': 'Algerian date-filled semolina cookies with honey',
        'price': 250.0,
        'imageUrl': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 35,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Jus d\'Orange',
        'description': 'Fresh squeezed orange juice from Algerian oranges',
        'price': 200.0,
        'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 73,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Salade Mechouia',
        'description': 'Grilled vegetable salad with olive oil and harissa',
        'price': 350.0,
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[1],
        'isAvailable': true,
        'orderCount': 48,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Amina Zerrouki - Traditional & Pastries
      {
        'name': 'Merguez Grillée',
        'description': 'Grilled Algerian lamb merguez with harissa and grilled onions',
        'price': 650.0,
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 55,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Pizza Algérienne',
        'description': 'Pizza with merguez, olives, and Algerian spices',
        'price': 800.0,
        'imageUrl': 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 42,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tiramisu Algérien',
        'description': 'Tiramisu with Algerian coffee and orange blossom water',
        'price': 400.0,
        'imageUrl': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 38,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Café Turc',
        'description': 'Traditional Turkish coffee served Algerian style',
        'price': 180.0,
        'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 89,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Pasta Merguez',
        'description': 'Pasta with spicy Algerian merguez and tomato sauce',
        'price': 550.0,
        'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[2],
        'isAvailable': true,
        'orderCount': 46,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Karim Messaoudi - Street Food & Pastries
      {
        'name': 'Chawarma Algérien',
        'description': 'Algerian shawarma with lamb, vegetables, and harissa sauce',
        'price': 450.0,
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 78,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Brik à l\'Oeuf',
        'description': 'Crispy phyllo pastry filled with egg, tuna, and capers',
        'price': 280.0,
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 65,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Msemen',
        'description': 'Algerian flatbread with honey and butter',
        'price': 120.0,
        'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 92,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Limonade',
        'description': 'Fresh Algerian lemonade with mint',
        'price': 180.0,
        'imageUrl': 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 85,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Zlabia',
        'description': 'Algerian honey-soaked pastries',
        'price': 200.0,
        'imageUrl': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[3],
        'isAvailable': true,
        'orderCount': 44,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Chef Leila Hamidi - Traditional & Drinks
      {
        'name': 'Couscous Végétarien',
        'description': 'Vegetarian couscous with seasonal vegetables and chickpeas',
        'price': 750.0,
        'imageUrl': 'https://images.unsplash.com/photo-1515443961218-a51367888e4b?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 39,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Tajine de Légumes',
        'description': 'Vegetable tagine with eggplant, zucchini, and tomatoes',
        'price': 600.0,
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 33,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Salade Algérienne',
        'description': 'Fresh salad with tomatoes, cucumbers, and olive oil',
        'price': 250.0,
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        'category': 'Traditional',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Traditional').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 51,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Thé à la Menthe',
        'description': 'Traditional Algerian mint tea with pine nuts',
        'price': 120.0,
        'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&h=300&fit=crop',
        'category': 'Drinks',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Drinks').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 76,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Ghriba',
        'description': 'Algerian coconut and almond cookies',
        'price': 180.0,
        'imageUrl': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&h=300&fit=crop',
        'category': 'Pastries',
        'categoryId': categories.firstWhere((doc) => doc.data()['name'] == 'Pastries').id,
        'chefId': chefIds[4],
        'isAvailable': true,
        'orderCount': 42,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Create dishes in Firestore
    for (final dishData in dishes) {
      await _firestore.collection('dishes').add(dishData);
    }
  }
} 