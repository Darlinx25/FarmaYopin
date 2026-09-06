import 'package:flutter/material.dart';

import '../models/purchase.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final Purchase purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('PurchaseDetailScreen'),
      ),
    );
  }
}