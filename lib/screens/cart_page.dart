// screens/cart_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:exclusive_fragrance/model/cart.dart';
import 'package:exclusive_fragrance/screens/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:exclusive_fragrance/screens/shop_page.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    Cart().addListener(_updateCart);
  }

  @override
  void dispose() {
    Cart().removeListener(_updateCart);
    super.dispose();
  }

  void _updateCart() => setState(() {});

  void _navigateToShop() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ShopPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      appBar: AppBar(
        title: Text('Cart',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E2832),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Cart().items.isEmpty
    ? _buildEmptyCart()
    : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: Cart().items.length,
              itemBuilder: (context, index) {
                final item = Cart().items[index];
                return _buildCartItem(item, context);
              },
            ),
          ),
          _buildCartSummary(),
        ],
      ),

    );
  }


  Widget _buildCartSummary() {
  final total = Cart().items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item.product.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0) * item.quantity);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Color(0xFF1E2832),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Checkout',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}


void _onCheckout() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Color(0xFF1E2832),
      title: Text('Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(
        'Proceeding to checkout...',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CheckoutPage()),
            );
          },
          child: Text('OK', style: TextStyle(color: Colors.green)),
        ),
      ],
    ),
  );
}


  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your cart is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E2832),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Color(0xFF1E2832),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.product.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.product.price,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white70),
                    onPressed: () {
                      final oldQuantity = item.quantity;
                      Cart().decreaseQuantity(item.product);
                      if (oldQuantity == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${item.product.name} removed from cart'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white70),
                    onPressed: () => Cart().increaseQuantity(item.product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
