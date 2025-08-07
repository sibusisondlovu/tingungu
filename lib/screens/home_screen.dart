import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tingungu_app/screens/buy_airtime_screen.dart';
import 'package:tingungu_app/screens/giving_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import 'profile_screen.dart';

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

  void _launchSermon(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open sermon video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tingungu', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Constants.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: (){
                  _navigateTo('Notices Page');
                },
                child: const Icon(Icons.notification_add, color: Colors.white)),
          ),
        ],
      ),
      drawer: _buildDrawer(),
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
             // _activateAccount(),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('This feature is not enabled in this version. Coming Soon!'),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                      backgroundColor: Constants.ascentColor,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }, // Navigate to Sell Page
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
    final sermons = [
      {
        'title': 'Faith Over Fear',
        'date': 'June 1, 2025',
        'url': 'https://www.youtube.com/watch?v=VIDEO_ID1',
      },
      {
        'title': 'The Power of Prayer',
        'date': 'May 25, 2025',
        'url': 'https://www.youtube.com/watch?v=VIDEO_ID2',
      },
      {
        'title': 'Walking in Grace',
        'date': 'May 18, 2025',
        'url': 'https://www.youtube.com/watch?v=VIDEO_ID3',
      },
    ];

    return Card(
      color: Constants.ascentColor.withOpacity(0.1),
      child: Column(
        children: sermons.map((sermon) {
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.play_circle_fill, color: Constants.primaryColor),
                title: Text(sermon['title']!),
                subtitle: Text(sermon['date']!),
                onTap: () => _launchSermon(sermon['url']!),
              ),
              if (sermon != sermons.last) const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _latestEventCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.ascentColor.withOpacity(0.5),
      child: ListTile(
        title: const Text(
          "Youth Revival Night",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Sat, June 15 · 6:00 PM"),
        trailing: const Icon(Icons.event),
        onTap: () {
          _showEventDetailsDialog(
            title: "Youth Revival Night",
            date: "Saturday, June 15, 2025",
            description:
            "Join us for a powerful night of worship, testimonies, and revival hosted by the Methodist Church Youth. All societies welcome. Starts at 6 PM sharp!",
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Giving'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GivingPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Tingungu'),
            onTap: () {
              Navigator.pop(context);
              _navigateTo('Navigate to About Tingungu Page');
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Log out logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            'Powered by Jaspa',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showEventDetailsDialog({
    required String title,
    required String date,
    required String description,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Constants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                  ),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        );
      },
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
                _navigateTo('Tingungu Store');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Buy Airtime'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyAirtimeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Buy Electricity'),
              onTap: () {
                Navigator.pop(context);
                _navigateTo('Buy Electricity');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Buy Data'),
              onTap: () {
                Navigator.pop(context);
                _navigateTo('Buy Data');
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
