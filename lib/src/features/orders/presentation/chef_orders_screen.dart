import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kouzinti/src/models/order_model.dart';
import 'package:kouzinti/src/services/order_service.dart';
import 'package:kouzinti/src/features/orders/presentation/order_detail_screen.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:kouzinti/src/widgets/error_widget.dart';
import 'package:kouzinti/src/widgets/empty_state_widget.dart';
import 'package:kouzinti/src/models/user_model.dart';
import 'package:kouzinti/src/services/auth_service.dart';

class ChefOrdersScreen extends StatelessWidget {
  const ChefOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final orderService = OrderService();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Incoming Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getChefOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingStateWidget(
                message: 'Loading chef orders...',
              ),
            );
          }

          if (snapshot.hasError) {
            return NetworkErrorWidget(
              customMessage: 'Error loading orders: ${snapshot.error}',
              onRetry: () {
                // This will trigger a rebuild and retry the query
              },
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const EmptyIncomingOrdersWidget();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return FutureBuilder<UserModel?>(
                future: AuthService().getUserById(order.userId),
                builder: (context, snapshot) {
                  final client = snapshot.data;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(orderId: order.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, 8)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (client != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Client: ${client.firstName} ${client.lastName}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (client.phoneNumber != null && client.phoneNumber!.isNotEmpty)
                                    Text(
                                      'Phone: ${client.phoneNumber}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  if (client.address != null && client.address!.isNotEmpty)
                                    Text(
                                      'Address: ${client.address}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ${order.total.toStringAsFixed(0)} DZD',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String newStatus) async {
                                    try {
                                      await orderService.updateOrderStatus(order.id, newStatus);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Order status updated to $newStatus'),
                                            backgroundColor: AppColors.primary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error updating order status: $e'),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'preparing',
                                      child: Text('Start Preparing'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'ready',
                                      child: Text('Mark as Ready'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delivered',
                                      child: Text('Mark as Delivered'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'cancelled',
                                      child: Text('Cancel Order'),
                                    ),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Update Status',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ordered on ${_formatDate(order.createdAt.toDate())}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        displayText = 'Pending';
        break;
      case 'preparing':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        displayText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Ready';
        break;
      case 'delivered':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 