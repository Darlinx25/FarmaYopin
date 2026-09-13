import 'package:flutter/material.dart';

import '../models/purchase.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFAF9),
    );
  }
}