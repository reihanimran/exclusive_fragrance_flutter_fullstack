import 'package:exclusive_fragrance/model/products.dart';
import 'package:flutter/material.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Product product) {
    final existingItem = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _notifyListeners();
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    _notifyListeners();
  }

  // Total price of items in the cart
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + (double.parse(item.product.price.toString()) * item.quantity));
  }


  void clearCart() {
    _items.clear();
    _notifyListeners();
  }

  void increaseQuantity(Product product) {
    final item = _items.firstWhere((item) => item.product.id == product.id);
    item.quantity++;
    _notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final item = _items.firstWhere((item) => item.product.id == product.id);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    _notifyListeners();
  }

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Listeners for state management
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
