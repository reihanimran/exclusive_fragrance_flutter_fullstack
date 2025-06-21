// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:exclusive_fragrance/model/cart.dart';
import 'package:exclusive_fragrance/model/products.dart';
import 'package:exclusive_fragrance/screens/cart_page.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isFavorite = false; // Track the heart icon state
  String selectedSize = '50ml'; // Track selected size
  int _cartItemCount = 0; // Track the number of items in the cart

  @override
  void initState() {
    super.initState();
    // Add a listener to the Cart to update the UI when the cart changes
    Cart().addListener(_updateCart);
    _updateCart(); // Initialize the cart item count
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    Cart().removeListener(_updateCart);
    super.dispose();
  }

  void _updateCart() {
    setState(() {
      _cartItemCount = Cart().totalItems;
    });
  }

  void _handleWishlist() {
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to Wishlist'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product removed from Wishlist'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAddToCart() {
    Cart().addItem(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to Cart'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.product.name,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF151E25),
        actions: [
          IconButton(
            onPressed: _handleWishlist,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
          Stack(
            children: [
              IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  }),
              if (_cartItemCount > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF151E25),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2832),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                    widget.product.image,
                    width: 310,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                        
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Amarante',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF5D57A),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.price,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  _buildSizeSelector(),
                  const SizedBox(height: 80), // Space for the fixed button
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF151E25),
            child: ElevatedButton(
              onPressed: _handleAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5D57A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Add to Cart",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF151E25),
                  fontFamily: 'Amarante',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Size:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: ['50ml', '100ml', '150ml'].map((size) {
            return ChoiceChip(
              label: Text(
                size,
                style: TextStyle(
                  color: selectedSize == size ? Colors.black : Colors.white,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              selected: selectedSize == size,
              selectedColor: const Color(0xFFF5D57A),
              backgroundColor: const Color(0xFF1E2832),
              onSelected: (selected) {
                setState(() {
                  selectedSize = size;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
