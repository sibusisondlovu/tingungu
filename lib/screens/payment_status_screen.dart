import 'package:flutter/material.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool success;
  const PaymentStatusScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(success ? 'Payment Successful' : 'Payment Cancelled', style: TextStyle(color: Colors.white, fontSize: 16),),
        backgroundColor: success ? Colors.green : Colors.red,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              success
                  ? '🎉 Your payment was successful!'
                  : '❌ Payment was cancelled.',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // ✅ Go back to previous screen
              },
              child: const Text('Back to App'),
            )
          ],
        ),
      ),
    );
  }
}
