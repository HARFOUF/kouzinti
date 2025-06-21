import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kouzinti/src/models/cart_item_model.dart';
import 'package:kouzinti/src/models/dish_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status; // e.g., 'pending', 'confirmed', 'delivered'
  final String address;
  final String phoneNumber;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'],
      items: (data['items'] as List<dynamic>)
          .map((item) => CartItem(
                // Create DishModel from the stored dish data
                dish: DishModel(
                  id: item['dish']['id'] ?? '',
                  name: item['dish']['name'] ?? '',
                  description: item['dish']['description'] ?? '',
                  price: (item['dish']['price'] ?? 0.0).toDouble(),
                  imageUrl: item['dish']['imageUrl'],
                  category: item['dish']['category'] ?? '',
                  categoryId: item['dish']['categoryId'] ?? '',
                  chefId: item['dish']['chefId'] ?? '',
                  isAvailable: item['dish']['isAvailable'] ?? true,
                  orderCount: item['dish']['orderCount'] ?? 0,
                  createdAt: item['dish']['createdAt'] ?? (doc['createdAt'] ?? Timestamp.now()),
                ),
                quantity: item['quantity'],
              ))
          .toList(),
      total: data['total'],
      status: data['status'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items
          .map((item) => {
                'dish': item.dish.toMap(), // Storing the whole dish object
                'quantity': item.quantity,
              })
          .toList(),
      'total': total,
      'status': status,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
    };
  }
} 