import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: Center(child: Text('OrderDetailPage ($orderId) — Phase 7')),
    );
  }
}
