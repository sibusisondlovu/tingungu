import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tingungu_app/screens/payfast_page.dart';

import '../utils/constants.dart';

class GivingPage extends StatefulWidget {
  static const String id = "givingScreen";

  const GivingPage({super.key});

  @override
  State<GivingPage> createState() => _GivingPageState();
}

class _GivingPageState extends State<GivingPage> {
  String? selectedGivingType;
  String? selectedSociety;
  List<String> societies = [];
  bool isLoadingSocieties = true;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchSocieties();
  }

  Future<void> fetchSocieties() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.tingungu.co.za/data/societie.json'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          societies = data.cast<String>();
          isLoadingSocieties = false;
        });
      } else {
        throw Exception('Failed to load societies');
      }
    } catch (e) {
      print('Error fetching societies: $e');
      setState(() {
        isLoadingSocieties = false;
      });
    }
  }

  Future<void> saveGiving() async {
    if (selectedGivingType == null ||
        selectedSociety == null ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('givings').add({
      'type': selectedGivingType,
      'amount': double.tryParse(amountController.text) ?? 0,
      'society': selectedSociety,
      'note': noteController.text,
      'giverName': user?.displayName ?? 'Anonymous',
      'giverUID': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Giving saved successfully!')),
    );

    // 👉 Later: trigger PayFast payment here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giving', style: TextStyle(fontSize: 16, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Constants.primaryColor,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notification_add, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Giving Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGivingType,
                items: ['Pledge', 'Donation', 'Tithe', 'Offering']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGivingType = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Choose type",
                ),
              ),
              SizedBox(height: 16),

              Text("Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              SizedBox(height: 16),

              Text("Select Society", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              isLoadingSocieties
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: selectedSociety,
                items: societies
                    .map((society) =>
                    DropdownMenuItem(value: society, child: Text(society)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSociety = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Choose society",
                ),
              ),
              SizedBox(height: 16),

              Text("Note (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: "Add a note",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.payment),
                  label: Text("Pay Now via PayFast", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PayFastWebView(
                          formData: {
                            'merchant_id': '10000100',
                            'merchant_key': '46f0cd694581a',
                            'return_url': 'https://www.example.com/success',
                            'cancel_url': 'https://www.example.com/cancel',
                            'notify_url': 'https://www.example.com/notify',
                            'name_first': 'John',
                            'name_last': 'Doe',
                            'm_payment_id': '01AB',
                            'amount': '100.00',
                            'item_name': 'Test Item',
                            'item_description': 'A test product',
                            'custom_int1': '2',
                            'custom_str1': 'Extra order information',
                            'email_address': 'john@doe.com',
                            'cell_number': '0823456789',
                          },
                        ),
                      ),
                    );
                   // await saveGiving();
                    // 👉 Will add PayFast integration here
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
