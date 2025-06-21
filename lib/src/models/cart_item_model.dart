import 'package:kouzinty/src/models/dish_model.dart';

class CartItem {
  final DishModel dish;
  int quantity;

  CartItem({required this.dish, this.quantity = 1});

  double get totalPrice => dish.price * quantity;
} 