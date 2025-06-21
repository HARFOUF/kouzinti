import 'package:flutter/foundation.dart';
import 'package:kouzinty/src/models/cart_item_model.dart';
import 'package:kouzinty/src/models/dish_model.dart';

class CartService with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(DishModel dish) {
    if (_items.containsKey(dish.id)) {
      _items.update(
        dish.id,
        (existingCartItem) => CartItem(
          dish: existingCartItem.dish,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        dish.id,
        () => CartItem(dish: dish),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String dishId) {
    if (!_items.containsKey(dishId)) return;
    if (_items[dishId]!.quantity > 1) {
      _items.update(
        dishId,
        (existingCartItem) => CartItem(
          dish: existingCartItem.dish,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(dishId);
    }
    notifyListeners();
  }

  void removeItem(String dishId) {
    _items.remove(dishId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
} 