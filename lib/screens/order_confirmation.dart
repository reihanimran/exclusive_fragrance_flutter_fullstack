import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final double totalAmount;

  const OrderConfirmationPage({
    required this.orderId,
    required this.totalAmount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151E25),
      appBar: AppBar(
        title: Text('Order Confirmation',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E2832),
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              SizedBox(height: 24),
              Text(
                'Order Confirmed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your order #$orderId has been placed successfully',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'Total Amount: Rs ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFFF5D57A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5D57A),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Color(0xFF151E25),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}