import 'package:flutter/material.dart';
import 'package:kouzinti/src/models/order_model.dart';
import 'package:kouzinti/src/services/order_service.dart';
import 'package:kouzinti/src/widgets/empty_state_widget.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:kouzinti/src/widgets/error_widget.dart';
import 'package:kouzinti/src/models/user_model.dart';
import 'package:kouzinti/src/services/auth_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<OrderModel?>(
        future: orderService.getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingStateWidget(
                message: 'Loading order details...',
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: ErrorStateWidget(
                message: 'Failed to load order: ${snapshot.error}',
                onRetry: () {
                  // Future will automatically retry
                },
              ),
            );
          }

          final order = snapshot.data;

          if (order == null) {
            return const Center(
              child: EmptyStateWidget(
                title: 'Order Not Found',
                message: 'The order you are looking for does not exist.',
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.grey,
                backgroundColor: Colors.grey,
              ),
            );
          }

          // Fetch both client and chef info
          final chefId = order.items.isNotEmpty ? order.items.first.dish.chefId : null;
          return FutureBuilder<UserModel?>(
            future: AuthService().getUserById(order.userId),
            builder: (context, clientSnapshot) {
              final client = clientSnapshot.data;
              return FutureBuilder<UserModel?>(
                future: chefId != null ? AuthService().getUserById(chefId) : null,
                builder: (context, chefSnapshot) {
                  final chef = chefSnapshot.data;
                  final currentUser = AuthService().currentUser;
                  final isChef = currentUser != null && currentUser.role == 'chef';
                  final isClient = currentUser != null && currentUser.role == 'client';
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Status Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.id.substring(0, 8)}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    _buildStatusBadge(order.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Total: ${order.total.toStringAsFixed(0)} DZD',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${_formatDate(order.createdAt.toDate())}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (isChef && client != null) ...[
                                  Text('Client:', style: Theme.of(context).textTheme.titleMedium),
                                  Text('${client.firstName} ${client.lastName}', style: Theme.of(context).textTheme.bodyLarge),
                                  if (client.phoneNumber != null && client.phoneNumber!.isNotEmpty)
                                    Text('Phone: ${client.phoneNumber}', style: Theme.of(context).textTheme.bodyMedium),
                                  if (client.address != null && client.address!.isNotEmpty)
                                    Text('Address: ${client.address}', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 8),
                                ],
                                if (isClient && chef != null) ...[
                                  Text('Chef:', style: Theme.of(context).textTheme.titleMedium),
                                  Text('${chef.firstName} ${chef.lastName}', style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Order Items
                        Text(
                          'Order Items',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...order.items.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.dish.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(0)} DZD',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ],
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
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        statusText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        statusText = 'Confirmed';
        break;
      case 'preparing':
        backgroundColor = Colors.purple;
        textColor = Colors.white;
        statusText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        statusText = 'Ready';
        break;
      case 'delivered':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        statusText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        statusText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 