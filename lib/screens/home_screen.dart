import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = 'homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tingungu', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notification_add, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome 👋,',
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _activateAccount(),
              const SizedBox(height: 20),
              _dailyVerseCard(),
              const SizedBox(height: 20),
              const Text(
                'Marketplace',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Constants.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _buySellCard(),
              const SizedBox(height: 20),
              const Text(
                'Latest Sermons',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Constants.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _latestSermonCard(),
              const SizedBox(height: 20),
              const Text(
                'Upcoming Event',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Constants.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _latestEventCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activateAccount() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constants.ascentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your account is not yet activated!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Please activate your account to access all features. Check your email for activation link',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.0),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              //TODO resend activation email
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
            ),
            child: const Text('RE-SEND EMAIL'),
          ),
        ],
      ),
    );
  }

  Widget _dailyVerseCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          alignment: Alignment.bottomRight,
        ),
        color: Constants.ascentColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Scripture of the Day',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            '"I can do all things through Christ who strengthens me."\n– Philippians 4:13',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buySellCard() {
    return Card(
      color: Constants.ascentColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {}, // Navigate to Sell Page
                child: Card(
                  color: Constants.primaryColor.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: const [
                        Icon(Icons.storefront, size: 32, color: Colors.white),
                        SizedBox(height: 8),
                        Text("Sell", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showBuyOptions();
                }, // Navigate to Buy Page
                child: Card(
                  color: Constants.primaryColor.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: const [
                        Icon(Icons.shopping_cart, size: 32, color: Colors.white),
                        SizedBox(height: 8),
                        Text("Buy", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestSermonCard() {
    return Card(
      color: Constants.ascentColor.withOpacity(0.1),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.play_circle_fill, color: Constants.primaryColor),
            title: const Text("Faith Over Fear"),
            subtitle: const Text("June 1, 2025"),
            onTap: () {}, // Navigate to sermon
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.play_circle_fill, color: Constants.primaryColor),
            title: const Text("The Power of Prayer"),
            subtitle: const Text("May 25, 2025"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _latestEventCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.ascentColor.withOpacity(0.5),
      child: ListTile(
        title: const Text("Youth Revival Night", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Sat, June 15 · 6:00 PM"),
        trailing: const Icon(Icons.event),
        onTap: () {}, // Link to Event Page
      ),
    );
  }

  void _showBuyOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Tingungu Store'),
              onTap: () {
                Navigator.pop(context);
                _navigateTo('store');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Buy Airtime'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'buyAirTineScreen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Buy Electricity'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'buyAirTineScreen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Buy Data'),
              onTap: () {
                Navigator.pop(context);
                _navigateTo('data');
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateTo(String type) {
    // TODO: Replace with actual navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to $type page')),
    );
  }

}
