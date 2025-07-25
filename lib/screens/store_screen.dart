import 'package:flutter/material.dart';

import '../utils/constants.dart'; // for Constants.primaryColor

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  static const String id = 'storeScreen';

  final List<Map<String, dynamic>> items = const [
    {"name": "Bible - KJV", "price": 150, "image": "assets/images/bible.png"},
    {"name": "Bible - Xhosa", "price": 180, "image": "assets/images/bible.png"},
    {"name": "Song Book", "price": 80, "image": "assets/images/songbook.png"},
    {"name": "Sunday Hat", "price": 120, "image": "assets/images/hat.png"},
    {"name": "Church T-Shirt", "price": 200, "image": "assets/images/tshirt.png"},
    {"name": "Branded Cup", "price": 50, "image": "assets/images/cup.png"},
    {"name": "Worship CD", "price": 100, "image": "assets/images/cd.png"},
    {"name": "Prayer Journal", "price": 60, "image": "assets/images/journal.png"},
    {"name": "Church Pin", "price": 20, "image": "assets/images/pin.png"},
    {"name": "Umbrella", "price": 90, "image": "assets/images/umbrella.png"},
    {"name": "Scarf", "price": 70, "image": "assets/images/scarf.png"},
    {"name": "Wristband", "price": 25, "image": "assets/images/band.png"},
    {"name": "Necklace", "price": 40, "image": "assets/images/necklace.png"},
    {"name": "Offering Envelope", "price": 15, "image": "assets/images/envelope.png"},
    {"name": "Church Flag", "price": 130, "image": "assets/images/flag.png"},
    {"name": "Backpack", "price": 250, "image": "assets/images/bag.png"},
    {"name": "Notebook", "price": 35, "image": "assets/images/notebook.png"},
    {"name": "Sermon USB", "price": 90, "image": "assets/images/usb.png"},
    {"name": "Bookmark", "price": 10, "image": "assets/images/bookmark.png"},
    {"name": "Worship Hoodie", "price": 300, "image": "assets/images/hoodie.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tingungu Store'),
        backgroundColor: Constants.primaryColor,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      item['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text('R${item['price']}'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This feature is not enabled yet.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: const Text("Add to Cart"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
