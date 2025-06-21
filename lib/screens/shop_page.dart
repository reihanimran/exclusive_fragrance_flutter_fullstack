import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:exclusive_fragrance/model/products.dart';
import 'package:exclusive_fragrance/screens/product_detail.dart';
import 'package:exclusive_fragrance/screens/product_card.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String selectedCategory = 'All';
  List<Product> products = [];
  bool isLoading = true;
  String errorMessage = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      debugPrint('Attempting to fetch products from API...');

      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      debugPrint('API response status: ${response.statusCode}');
      debugPrint('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Navigate to the products list inside the response
        final dynamic productsData = decoded['products'];
        if (productsData is Map && productsData['data'] is List) {
          final List<dynamic> data = productsData['data'];

          setState(() {
            products = data.map((json) => Product.fromJson(json)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid product data format');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load products. Please try again later.';
      });
    }
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      if (selectedCategory == 'All') return true;
      return product.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5D57A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF151E25)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2832),
        title: const Text(
          'Shop',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _fetchProducts,
        color: const Color(0xFFF5D57A),
        backgroundColor: const Color(0xFF151E25),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All']
                            .map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = category;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: selectedCategory == category
                                            ? const Color(0xFFF5D57A)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: const Color(0xFFF5D57A),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: selectedCategory == category
                                              ? const Color(0xFF151E25)
                                              : Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFF5D57A)),
                ),
              )
            else if (errorMessage.isNotEmpty)
              SliverFillRemaining(
                child: _buildErrorWidget(),
              )
            else if (filteredProducts.isEmpty)
              SliverFillRemaining(
                child: const Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 4 : 2,
                    childAspectRatio: isLandscape ? 0.6 : 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
