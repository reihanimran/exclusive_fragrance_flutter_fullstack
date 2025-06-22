// ignore_for_file: prefer_const_constructors

import 'package:exclusive_fragrance/model/cart.dart';
import 'package:flutter/material.dart';
import 'package:exclusive_fragrance/screens/homepage.dart';
import 'package:exclusive_fragrance/screens/shop_page.dart';
import 'package:exclusive_fragrance/screens/cart_page.dart';
import 'package:exclusive_fragrance/screens/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  int _cartItemCount = 0;
  String? _profilePhotoUrl;
  bool _isLoadingProfile = true;

  final List<Widget> _screens = [
    HomePage(),
    ShopPage(),
    CartPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Add a listener to the Cart to update the UI when the cart changes
    Cart().addListener(_updateCart);
    _updateCart(); // Initialize the cart item count
    _loadUserProfile(); // Load user profile data
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

  Future<void> _loadUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _profilePhotoUrl = userData['profile_photo_url'];
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildProfileIcon() {
    if (_isLoadingProfile) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _selectedIndex == 3 ? Color(0xFFF5D57A) : Colors.grey,
          ),
        ),
      );
    }

    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _profilePhotoUrl!,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _selectedIndex == 3 ? Color(0xFFF5D57A) : Colors.grey,
                ),
              ),
            );
          },
        ),
      );
    }

    return Icon(Icons.person);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF151E25),
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color(0xFFF5D57A),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
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
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: _buildProfileIcon(),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
