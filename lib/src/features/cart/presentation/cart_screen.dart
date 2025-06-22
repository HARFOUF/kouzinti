import 'package:flutter/material.dart';
import 'package:kouzinti/src/features/orders/presentation/checkout_screen.dart';
import 'package:kouzinti/src/services/cart_service.dart';
import 'package:kouzinti/src/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const EmptyCartWidget()
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Dismissible(
                        key: ValueKey(cartItem.dish.id),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          child: const Icon(Icons.delete, color: Colors.white, size: 40),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          Provider.of<CartService>(context, listen: false).removeItem(cartItem.dish.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: cartItem.dish.imageUrl != null 
                                    ? NetworkImage(cartItem.dish.imageUrl!)
                                    : null,
                                child: cartItem.dish.imageUrl == null 
                                    ? const Icon(Icons.restaurant)
                                    : null,
                              ),
                              title: Text(cartItem.dish.name),
                              subtitle: Text('Total: ${(cartItem.totalPrice).toStringAsFixed(0)} DZD'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      cart.removeSingleItem(cartItem.dish.id);
                                    },
                                  ),
                                  Text('${cartItem.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cart.addItem(cartItem.dish);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  Chip(
                    label: Text(
                      '${cart.totalAmount.toStringAsFixed(0)} DZD',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text('CHECKOUT'),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
} 