// ignore_for_file: prefer_const_constructors

import 'package:exclusive_fragrance/model/cart.dart';
import 'package:exclusive_fragrance/model/products.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false; // Track the heart icon state

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
    setState(() {
      isFavorite = false; // Remove from wishlist when added to cart
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to Cart'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
    // Add your logic to add the product to the cart here
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2832),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.product.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Amarante',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.price,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _handleAddToCart, // Call the new method
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF5D57A)),
                    foregroundColor: const Color(0xFFF5D57A),
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFF5D57A),
                      fontFamily: 'Amarante',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: _handleWishlist,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : const Color(0xFFF5D57A),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
