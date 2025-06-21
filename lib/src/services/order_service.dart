import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kouzinti/src/models/order_model.dart';
import 'package:kouzinti/src/models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order
  Future<void> createOrder({
    required List<CartItem> items,
    required String address,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    final orderData = {
      'userId': user.uid,
      'items': items.map((item) => {
        'dish': item.dish.toMap(),
        'quantity': item.quantity,
      }).toList(),
      'total': total,
      'status': 'pending',
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('orders').add(orderData);
  }

  // Get orders for a specific user
  Stream<List<OrderModel>> getUserOrders(String userId) {
    try {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      // If index is not available, use a simpler query without ordering
      if (e.toString().contains('failed-precondition') || e.toString().contains('requires an index')) {
        return _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .map((snapshot) {
              final orders = snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList();
              // Sort manually in Dart
              orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return orders;
            });
      }
      rethrow;
    }
  }

  // Get orders for a specific chef (orders containing their dishes)
  Stream<List<OrderModel>> getChefOrders(String chefId) {
    try {
      // First try with a simple query and filter in Dart
      return _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final orders = snapshot.docs
                .map((doc) => OrderModel.fromFirestore(doc))
                .where((order) => order.items.any((item) => item.dish.chefId == chefId))
                .toList();
            return orders;
          });
    } catch (e) {
      // If ordering fails, get all orders and filter/sort in Dart
      if (e.toString().contains('failed-precondition') || e.toString().contains('requires an index')) {
        return _firestore
            .collection('orders')
            .snapshots()
            .map((snapshot) {
              final orders = snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .where((order) => order.items.any((item) => item.dish.chefId == chefId))
                  .toList();
              // Sort manually in Dart
              orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return orders;
            });
      }
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get a single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromFirestore(doc);
    }
    return null;
  }
} 