import 'package:exclusive_fragrance/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:exclusive_fragrance/model/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  double _cartTotal = 0;
  double _shippingCost = 500.00;
  double _grandTotal = 0;

  // Form fields
  String _fullName = '';
  String _address = '';
  String _city = '';
  String _postalCode = '';
  String _phone = '';
  String _paymentMethod = 'credit_card';

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('http://13.60.243.207/api/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Parse shipping details
          final shippingDetails = data['shipping_details'];
          if (shippingDetails != null) {
            setState(() {
              _fullName = shippingDetails['full_name'] ?? '';
              _address = shippingDetails['address'] ?? '';
              _city = shippingDetails['city'] ?? '';
              _postalCode = shippingDetails['postal_code'] ?? '';
              _phone = shippingDetails['phone'] ?? '';
            });
          }

          // Parse cart and totals
          setState(() {
            _cartTotal = (data['cart_total'] ?? 0).toDouble();
            _shippingCost = (data['shipping_cost'] ?? 500).toDouble();
            _grandTotal = (data['grand_total'] ?? 0).toDouble();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading checkout data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processCheckout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = prefs.getString('token') ?? '';
      final response = await http.post(
        Uri.parse('http://13.60.243.207/api/checkout/process'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_name': _fullName,
          'address': _address,
          'city': _city,
          'postal_code': _postalCode,
          'phone': _phone,
          'payment_method': _paymentMethod,
          'cart_items': Cart()
              .items
              .map((item) => {
                    'product_id': item.product.id,
                    'quantity': item.quantity,
                  })
              .toList(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Clear the cart
        Cart().clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(responseData['message'] ?? 'Order placed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to home page while preserving bottom navigation
        Navigator.of(context).popUntil((route) => route.isFirst);

        // If you need to specifically navigate to the home tab in your bottom navigation
        // You'll need to use a state management solution or a callback
        // For example, if you're using a global method to set the active tab:
        // AppStateManager.setActiveTab(0); // Assuming 0 is the index of your home tab
      } else {
        throw Exception(responseData['message'] ?? 'Checkout failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      appBar: AppBar(
        title: Text('Checkout',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E2832),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFF5D57A)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Information',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'Full Name',
                      initialValue: _fullName,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your full name' : null,
                      onSaved: (value) => _fullName = value!,
                    ),
                    _buildTextFormField(
                      label: 'Address',
                      initialValue: _address,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your address' : null,
                      onSaved: (value) => _address = value!,
                    ),
                    _buildTextFormField(
                      label: 'City',
                      initialValue: _city,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your city' : null,
                      onSaved: (value) => _city = value!,
                    ),
                    _buildTextFormField(
                      label: 'Postal Code',
                      initialValue: _postalCode,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter postal code' : null,
                      onSaved: (value) => _postalCode = value!,
                    ),
                    _buildTextFormField(
                      label: 'Phone Number',
                      initialValue: _phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter phone number' : null,
                      onSaved: (value) => _phone = value!,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildPaymentMethodRadio('Credit Card', 'credit_card'),
                    _buildPaymentMethodRadio('PayPal', 'paypal'),
                    _buildPaymentMethodRadio('Cash on Delivery', 'cod'),
                    SizedBox(height: 24),
                    _buildOrderSummary(),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF5D57A),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Complete Order',
                          style: TextStyle(
                            color: Color(0xFF151E25),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    String? initialValue,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF5D57A)),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildPaymentMethodRadio(String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (String? value) {
        setState(() {
          _paymentMethod = value!;
        });
      },
      activeColor: Color(0xFFF5D57A),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E2832),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', 'Rs ${_cartTotal.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Shipping', 'Rs ${_shippingCost.toStringAsFixed(2)}'),
          Divider(color: Colors.white54),
          _buildSummaryRow(
            'Total',
            'Rs ${_grandTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Color(0xFFF5D57A) : Colors.white,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
