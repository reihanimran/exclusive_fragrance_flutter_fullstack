import 'package:exclusive_fragrance/model/cart.dart';
import 'package:exclusive_fragrance/model/products.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Product product) {
    _cart.addItem(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeItem(product);
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    _cart.increaseQuantity(product);
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    _cart.decreaseQuantity(product);
    notifyListeners();
  }
}
