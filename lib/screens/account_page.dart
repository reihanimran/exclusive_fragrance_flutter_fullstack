import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:exclusive_fragrance/screens/login_and_register.dart';
import 'package:exclusive_fragrance/utils/handle_user_login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? _address = 'Loading...';
  bool _locationError = false;
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _getCurrentLocation();
    fetchOrders();
  }

  Future<void> _getCurrentLocation() async {
    if (_locationLoading) return;

    setState(() {
      _locationLoading = true;
      _locationError = false;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw Exception('Location services are disabled');
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw Exception('Location permission permanently denied');
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permission not granted');
      }

      // Try getting location with high accuracy, fallback to low
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));
      }

      // Get address with retry logic
      await _getAddressWithRetry(position);
    } catch (e) {
      _handleLocationError('Error getting location: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _getAddressWithRetry(Position position,
      {int retryCount = 0}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address = _formatAddress(place);

        if (mounted) {
          setState(() {
            _address = address;
            _locationError = false;
          });
        }
      } else {
        throw Exception('No address information found');
      }
    } catch (e) {
      if (retryCount < 2) {
        await Future.delayed(const Duration(seconds: 1));
        await _getAddressWithRetry(position, retryCount: retryCount + 1);
      } else {
        if (mounted) {
          setState(() {
            _address = 'Address not found';
            _locationError = true;
          });
        }
        print('Address lookup failed: $e');
      }
    }
  }

  String _formatAddress(Placemark place) {
    final addressParts = [
      place.street,
      place.subLocality,
      place.locality,
      place.postalCode,
      place.country
    ].where((part) => part != null && part.isNotEmpty).toList();

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Address not available';
  }

  void _handleLocationError(String message) {
    print(message); // For debugging
    if (mounted) {
      setState(() {
        _address = 'Unable to get address';
        _locationError = true;
      });
    }
  }

  Future<void> fetchUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/user/profile'),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            userData = json.decode(response.body);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user information')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //fetch orders
  Future<void> fetchOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/orders'),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            // Handle paginated response - extract 'data' field
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('data')) {
              userData!['orders'] = responseData['data'];
            } else if (responseData is List) {
              // In case the response is directly a list
              userData!['orders'] = responseData;
            } else {
              userData!['orders'] = [];
            }
          });
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      appBar: AppBar(
        title: Text('My Account',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF151E25),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : userData == null
              ? Center(
                  child: Text('Failed to load user info',
                      style: TextStyle(color: Colors.white)))
              : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildAccountSection(),
                    SizedBox(height: 16),
                    _buildShippingInfo(),
                    SizedBox(height: 16),
                    _buildOrderHistory(),
                    SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ],
                ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      color: Color(0xFF1E2832),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Information',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Divider(color: Colors.white24),
            _buildInfoRow('Name', userData!['name']),
            _buildInfoRow('Email', userData!['email']),
            _buildInfoRow('Phone', userData!['contact_number'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      color: Color(0xFF1E2832),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Address',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Divider(color: Colors.white24),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userData?['shipping_address'] ?? 'No address found',
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  if (_locationLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white60,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Getting location...',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    )
                  else if (_locationError)
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(_address!,
                            style:
                                TextStyle(color: Colors.orange, fontSize: 13)),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.white60),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(_address!,
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 13)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _locationLoading ? null : _getCurrentLocation,
                child: Text(
                  _locationError ? 'Retry Location' : 'Update Location',
                  style: TextStyle(color: Color(0xFF00C4FF)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory() {
    List orders = userData!['orders'] ?? [];

    return Card(
      color: Color(0xFF1E2832),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order History',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Divider(color: Colors.white24),
            if (orders.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('No orders yet',
                      style: TextStyle(color: Colors.white70)),
                ),
              )
            else
              ...orders.map<Widget>((order) => _buildOrderItem(order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    // Add null checks and default values
    final orderId = order['id']?.toString() ?? 'N/A';
    final status = order['order_status']?.toString() ?? 'Pending';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;

    // Fix the items handling - items should be a List of order items
    List<String> itemsList = [];
    final itemsData = order['items'];

    if (itemsData != null && itemsData is List) {
      itemsList = itemsData.map<String>((item) {
        if (item is Map<String, dynamic>) {
          // Extract product name from the nested structure
          final product = item['product'];
          if (product != null && product is Map<String, dynamic>) {
            final productName =
                product['name']?.toString() ?? 'Unknown Product';
            final quantity = item['quantity']?.toString() ?? '1';
            return '$productName (x$quantity)';
          }
          return 'Product (x${item['quantity'] ?? 1})';
        }
        return item.toString();
      }).toList();
    }

    final rawDate = order['order_date']?.toString();
    String formattedDate = 'Unknown date';

    if (rawDate != null) {
      try {
        final parsedDate = DateTime.parse(rawDate);
        formattedDate = DateFormat('dd MMM yyyy, h:mm a').format(parsedDate);
      } catch (e) {
        // If parsing fails, fallback to raw string
        formattedDate = rawDate;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order $orderId',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
              Text(
                status,
                style: TextStyle(
                  color: status.toLowerCase() == 'delivered'
                      ? Colors.green
                      : Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: TextStyle(color: Colors.white70)),
              Text(
                'Rs ${total.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 4),
          if (itemsList.isNotEmpty)
            Text(
              itemsList.join(', '),
              style: TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Divider(color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2A3440),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color(0xFF1E2832),
              title: Text('Log Out', style: TextStyle(color: Colors.white)),
              content: Text('Are you sure you want to log out?',
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    HandleUserLogin.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => LoginRegisterScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text('Log Out', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        child:
            Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$title: ',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
