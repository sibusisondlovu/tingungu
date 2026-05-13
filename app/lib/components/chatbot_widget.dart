import 'package:flutter/material.dart';
import '../screens/giving_page.dart';
import '../screens/store_screen.dart';
import '../screens/media_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notices_screen.dart';
import '../screens/top_up_wallet.dart';
import '../screens/buy_airtime_screen.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Hello! I am your Tingungu Assistant. How can I help you today?',
      'options': [
        'How do I give?',
        'Where is the marketplace?',
        'How to top up wallet?',
        'I want to buy airtime',
        'What payment methods do you accept?',
        'How do I use my wallet?',
        'Help with navigation'
      ]
    }
  ];

  void _handleOption(String option) {
    setState(() {
      _messages.add({'isBot': false, 'text': option});
    });

    String response = '';
    Widget? targetScreen;

    switch (option) {
      case 'How do I give?':
        response = 'You can give by clicking on the "Give" button. You can choose to pay from your Wallet, Google Pay, or PayFast.';
        targetScreen = const GivingPage();
        break;
      case 'Where is the marketplace?':
        response = 'Our marketplace has various products. You can pay using your Wallet, Google Pay, or PayFast at checkout.';
        targetScreen = const StoreScreen();
        break;
      case 'How to top up wallet?':
        response = 'To top up, go to the Home screen and click "TOP UP" on your wallet card. You can use Google Pay or PayFast.';
        targetScreen = const TopUpWalletScreen();
        break;
      case 'I want to buy airtime':
        response = 'I will open the airtime screen. You can buy airtime using your Wallet, Google Pay, or PayFast.';
        targetScreen = const BuyAirtimeScreen();
        break;
      case 'What payment methods do you accept?':
        response = 'We accept Tingungu Wallet balance, Google Pay, and PayFast (which includes Cards, Instant EFT, and more).';
        break;
      case 'How do I use my wallet?':
        response = 'Your wallet balance can be used for any purchase in the app. Just select "Tingungu Wallet" as your payment method during checkout.';
        break;
      case 'Help with navigation':
        response = 'You can access all features from the side menu (click the 3 lines at the top left). You can find Media, Marketplace, Giving, and your Profile there.';
        break;
      default:
        response = 'I am not sure about that. Try one of the options below!';
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          'isBot': true,
          'text': response,
          'action': targetScreen != null ? 'Go there' : null,
          'target': targetScreen,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF3B0D11),
                  child: Icon(Icons.smart_toy_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tingungu Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B0D11)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  crossAxisAlignment: msg['isBot'] ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg['isBot'] ? Colors.white : const Color(0xFFFB8B24),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(msg['isBot'] ? 0 : 16),
                          bottomRight: Radius.circular(msg['isBot'] ? 16 : 0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: msg['isBot'] ? const Color(0xFF3B0D11) : Colors.white,
                        ),
                      ),
                    ),
                    if (msg['isBot'] && msg['options'] != null)
                      Wrap(
                        spacing: 8,
                        children: (msg['options'] as List<String>).map((opt) {
                          return ActionChip(
                            label: Text(opt, style: const TextStyle(fontSize: 12)),
                            onPressed: () => _handleOption(opt),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFFB8B24)),
                            labelStyle: const TextStyle(color: Color(0xFFFB8B24)),
                          );
                        }).toList(),
                      ),
                    if (msg['isBot'] && msg['action'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => msg['target']));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB8B24),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(msg['action']),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
