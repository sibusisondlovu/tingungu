import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class BuyAirtimeScreen extends StatefulWidget {
  const BuyAirtimeScreen({super.key});

  static const String id ="buyAirTineScreen";
  @override
  State<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends State<BuyAirtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedNetwork = 'MTN';
  final List<String> _networks = ['MTN', 'Vodacom', 'Cell C', 'Telkom'];

  final List<String> _quickAmounts = ['10', '20', '50', '100'];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> processPayment(String amount, String network, String phone) async {
    final itemName = Uri.encodeComponent('Airtime Top-up');
    final itemDescription = Uri.encodeComponent('$network Airtime for $phone');
    final base = 'https://payment.payfast.io/eng/process';
    final query = 'cmd=_paynow&receiver=14362369'
        '&item_name=$itemName'
        '&email_confirmation=1'
        '&confirmation_address=conferencendlovu@gmail.com'
        '&item_description=$itemDescription'
        '&return_url=https://www.tingungu.co.za/success'
        '&cancel_url=https://www.tingungu.co.za/cancel'
        '&notify_url=https://www.tingungu.co.za/notify'
        '&amount=${Uri.encodeComponent(amount)}';

    final uri = Uri.parse('$base?$query');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SpinKitCircle(color: Colors.deepPurple, size: 50),
            SizedBox(height: 16),
            Text("Processing Payment..."),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();

    try {
      Navigator.of(context).pop();
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'launchUrl returned false';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Airtime'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.length < 10 ? 'Enter a valid number' : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'Amount (R)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Amount required' : null,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _quickAmounts.map((amt) {
                  return ChoiceChip(
                    label: Text('R$amt'),
                    selected: _amountController.text == amt,
                    onSelected: (_) {
                      setState(() {
                        _amountController.text = amt;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const Text(
                'Select Network',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedNetwork,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _networks
                    .map((network) => DropdownMenuItem(
                  value: network,
                  child: Text(network),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedNetwork = value);
                  }
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    processPayment("50","MTN-59","0826468770");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(fontSize: 16),
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
