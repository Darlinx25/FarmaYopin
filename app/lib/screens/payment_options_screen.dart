import 'package:flutter/material.dart';

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('PaymentOptionsScreen'),
      ),
    );
  }
}