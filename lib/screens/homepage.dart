// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:exclusive_fragrance/model/products.dart';
import 'package:exclusive_fragrance/screens/product_detail.dart';
import 'package:exclusive_fragrance/widgets/search-bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:provider/provider.dart';
import 'product_card.dart';
import 'package:exclusive_fragrance/provider/network_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> bestSellerProducts = [];
  bool isLoading = true;
  String errorMessage = '';
  int batteryLevel = 0;
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _initBattery();
    fetchProducts();
  }

  Future<void> _initBattery() async {
    try {
      batteryLevel = await _battery.batteryLevel;
      _battery.onBatteryStateChanged.listen((BatteryState state) async {
        batteryLevel = await _battery.batteryLevel;
        if (mounted) setState(() {});
      });
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error getting battery level: $e');
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print(response.body);
        final decoded = json.decode(response.body);
        // Navigate to the products list inside the response
        final List<dynamic> data = decoded['products']['data'];
        final List<Product> fetchedProducts =
            data.map((json) => Product.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            bestSellerProducts = fetchedProducts
                .where((product) => product.isBestSeller)
                .toList();

            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load products. Please try again.';
        });
      }
      debugPrint('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<NetworkProvider>(context).isOnline;

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Header
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Search
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).padding.top + 20, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '$batteryLevel%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Expanded(child: SearchProductBar()),
                        SizedBox(width: 16),
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            if (!isConnected)
              Container(
                color: Colors.redAccent,
                width: double.infinity,
                padding: EdgeInsets.all(8),
                child: Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            // Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              color: Color(0xFFF5D57A),
              child: Text(
                '20% OFF on Your First Purchase - Use Code EF20%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF151E25),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 32),

            // Content based on loading state
            if (isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: CircularProgressIndicator(color: Color(0xFFF5D57A)),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF5D57A),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Color(0xFF151E25)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Hero Image and Text
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/hero_image.png',
                        width: isLandscape ? screenWidth * 0.8 : null,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'OUR ',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'Amarante',
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: 'PREMIUM ',
                            style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFFF5D57A),
                                fontFamily: 'Amarante',
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: 'COLLECTION',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'Amarante',
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),

              // Best Sellers Grid
              Padding(
                padding: EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: bestSellerProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isLandscape ? 0.6 : 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = bestSellerProducts[index];
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
