import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tingungu_app/utils/constants.dart';

class SocietySelectionPage extends StatefulWidget {
  final String currentSociety;
  static const String id = "societySelectionScreen";

  const SocietySelectionPage({super.key, required this.currentSociety});

  @override
  State<SocietySelectionPage> createState() => _SocietySelectionPageState();
}

class _SocietySelectionPageState extends State<SocietySelectionPage> {
  List<String> societies = [];
  List<String> filteredSocieties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSocieties();
  }

  Future<void> fetchSocieties() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.tingungu.co.za/data/societies.json'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          societies = data.cast<String>();
          filteredSocieties = societies;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load societies');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching societies: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSocieties(String query) {
    setState(() {
      filteredSocieties = societies
          .where((society) =>
          society.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> updateSociety(String selectedSociety) async {
    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'society': selectedSociety});

    Navigator.pop(context); // close screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        iconTheme: IconThemeData(color: Colors.white), // makes the back icon white
        title: Text(
          'Select Society',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type name of society...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: filterSocieties,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSocieties.length,
              itemBuilder: (context, index) {
                final society = filteredSocieties[index];
                return ListTile(
                  title: Text(society),
                  trailing: society == widget.currentSociety
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => updateSociety(society),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
