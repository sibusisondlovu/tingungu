import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'thank_you_screen.dart';

class StoreScreen extends StatefulWidget {
  final bool showCart;
  const StoreScreen({super.key, this.showCart = false});
  static const String id = 'storeScreen';

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    _loadCart();
    if (widget.showCart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCart(context));
    }
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('marketplace_cart');
    if (cartString != null) {
      final Map<String, dynamic> decoded = json.decode(cartString);
      setState(() {
        decoded.forEach((key, value) {
          _cart[key] = value as int;
        });
      });
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('marketplace_cart', json.encode(_cart));
  }

  final Map<String, int> _cart = {}; // productId -> quantity

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
      _saveCart();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added to cart'), duration: Duration(seconds: 1), backgroundColor: Colors.green),
    );
  }

  void _showCart(BuildContext context) async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty'), backgroundColor: Color(0xFF3B0D11)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF9F6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _CartBottomSheet(
        cart: _cart, 
        onUpdateQuantity: (id, qty) {
          setState(() {
            if (qty <= 0) {
              _cart.remove(id);
              _saveCart();
            } else {
              _cart[id] = qty;
              _saveCart();
            }
          });
        },
        onCheckoutComplete: () {
          setState(() { _cart.clear(); });
          _saveCart();
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = _cart.values.fold(0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF3B0D11),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCart(context),
              ),
              if (totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFFB8B24), shape: BoxShape.circle),
                    child: Text(
                      totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFB8B24)));
          }

          final products = snapshot.data!.docs;
          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Icon(Icons.storefront, size: 50, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Unknown',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Spacer(),
                            Text(
                              'R ${data['price']?.toString() ?? '0.00'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B0D11)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _addToCart(product.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFB8B24),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: const Text('Add', style: TextStyle(fontSize: 12)),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CartBottomSheet extends StatefulWidget {
  final Map<String, int> cart;
  final Function(String, int) onUpdateQuantity;
  final VoidCallback onCheckoutComplete;

  const _CartBottomSheet({
    required this.cart, 
    required this.onUpdateQuantity,
    required this.onCheckoutComplete
  });

  @override
  State<_CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<_CartBottomSheet> {
  bool _isProcessing = false;

  Future<void> _checkout(double total) async {
    setState(() => _isProcessing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) throw Exception("User not found");

        final balance = (snapshot.data()?['wallet_balance'] ?? 0.0).toDouble();
        if (balance < total) {
          throw Exception("Insufficient wallet balance");
        }

        // Deduct balance
        transaction.update(docRef, {'wallet_balance': balance - total});

        // Record transaction
        final txRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('transactions').doc();
        transaction.set(txRef, {
          'amount': total,
          'type': 'Marketplace Purchase',
          'date': FieldValue.serverTimestamp(),
          'items': widget.cart,
        });
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ThankYouScreen(amount: total)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B0D11))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('products').where(FieldPath.documentId, whereIn: widget.cart.keys.toList()).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFB8B24)));
              
              final products = snapshot.data!.docs;
              double total = 0;

              return Column(
                children: [
                  ...products.map((p) {
                    final data = p.data() as Map<String, dynamic>;
                    final price = (data['price'] ?? 0.0).toDouble();
                    final qty = widget.cart[p.id] ?? 0;
                    if (qty == 0) return const SizedBox.shrink();
                    total += price * qty;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('R $price', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                                onPressed: () {
                                  widget.onUpdateQuantity(p.id, qty - 1);
                                  setState(() {});
                                },
                              ),
                              Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFB8B24), size: 20),
                                onPressed: () {
                                  widget.onUpdateQuantity(p.id, qty + 1);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('R ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3B0D11))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _checkout(total),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B0D11),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

