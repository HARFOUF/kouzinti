import 'package:cloud_firestore/cloud_firestore.dart';

class DishModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final String categoryId;
  final String chefId;
  final bool isAvailable;
  final int orderCount;
  final Timestamp createdAt;

  DishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.categoryId,
    required this.chefId,
    required this.isAvailable,
    this.orderCount = 0,
    required this.createdAt,
  });

  factory DishModel.fromFirestore(DocumentSnapshot doc) {
    try {
      Map data = doc.data() as Map<String, dynamic>;
      return DishModel(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] ?? 0.0).toDouble(),
        imageUrl: data['imageUrl'],
        category: data['category'] ?? '',
        categoryId: data['categoryId'] ?? '',
        chefId: data['chefId'] ?? '',
        isAvailable: data['isAvailable'] ?? true,
        orderCount: data['orderCount'] ?? 0,
        createdAt: data['createdAt'] ?? Timestamp.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'categoryId': categoryId,
      'chefId': chefId,
      'isAvailable': isAvailable,
      'orderCount': orderCount,
      'createdAt': createdAt,
    };
  }

  DishModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? categoryId,
    String? chefId,
    bool? isAvailable,
    int? orderCount,
    Timestamp? createdAt,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      chefId: chefId ?? this.chefId,
      isAvailable: isAvailable ?? this.isAvailable,
      orderCount: orderCount ?? this.orderCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 