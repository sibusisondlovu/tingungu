import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../data/event_model.dart';

import '../data/scripture_model.dart';

import 'buy_airtime_screen.dart';
import '../services/scripture_service.dart';
import 'community_screen.dart';
import 'events_screen.dart';
import 'media_screen.dart';
import 'top_up_wallet.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Scripture? dailyScripture;
  bool _isLoadingScripture = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = 'Guest';
  String userEmail = '';
  String userPhone = '';
  String userAvatar = '';
  String timeGreeting = 'Good Morning';

  bool _isLoadingProfile = true;

  double walletBalance = 0.0;
  bool _isLoadingWallet = true;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadDailyScripture();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final balance = prefs.getDouble('wallet_balance') ?? 0.0;

      // Alternatively, load from Firestore
      // final userId = 'current_user_id'; // Replace with actual user ID from auth
      // final doc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .get();
      //
      // if (doc.exists) {
      //   final userData = doc.data() ?? {};
      //   balance = userData['wallet_balance']?.toDouble() ?? 0.0;
      // }

      if (mounted) {
        setState(() {
          walletBalance = balance;
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading wallet balance: $e');
      }
      if (mounted) {
        setState(() {
          _isLoadingWallet = false;
        });
      }
    }
  }

  Future<void> _loadDailyScripture() async {
    try {
      final scripture = await ScriptureService.getRandomScripture();
      setState(() {
        dailyScripture = scripture;
        _isLoadingScripture = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading scripture: $e');
      }
      setState(() {
        _isLoadingScripture = false;
      });
    }
  }


  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_profile');

      if (userJson != null) {
        // Load from SharedPreferences
        final userData = jsonDecode(userJson);
        setState(() {
          userName = userData['name'] ?? 'Guest';
          userEmail = userData['email'] ?? '';
          userPhone = userData['phone'] ?? '';
          userAvatar = userData['avatar'] ?? '';
          _isLoadingProfile = false;
        });
      } else {
        // Load from Firestore
        await _loadFromFirestore();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile: $e');
      }
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      final userId = 'current_user_id'; // Replace with actual user ID from auth
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final userData = doc.data() ?? {};
        setState(() {
          userName = userData['name'] ?? 'Guest';
          userEmail = userData['email'] ?? '';
          userPhone = userData['phone'] ?? '';
          userAvatar = userData['avatar'] ?? '';
        });

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', jsonEncode(userData));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading from Firestore: $e');
      }
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {

      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF85)),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 24),
                    _buildWalletCard(),
                    const SizedBox(height: 24),
                    _buildScriptureCard(),
                    const SizedBox(height: 28),
                    _buildMarketplace(),
                    const SizedBox(height: 28),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF0000)),
            ),
          ),
          const Text(
            'Tingungu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF0000),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Badge(
              label: const Text('3'),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFFF0000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$timeGreeting, $userName! 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF0000),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome to your spiritual journey',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildScriptureCard() {
    if (dailyScripture == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF85).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF85)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF85).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Scripture',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B7355),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dailyScripture!.text,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFFFF0000),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dailyScripture!.reference,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD4AF85),
                ),
              ),
              Text(
                dailyScripture!.translation,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF0000),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMarketplaceCard(
                icon: Icons.shopping_cart_outlined,
                label: 'Buy',
                color: const Color(0xFF5B8FA3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMarketplaceCard(
                icon: Icons.local_offer_outlined,
                label: 'Sell',
                color: const Color(0xFFD4AF85),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketplaceCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Buy') {
          _showBuyBottomSheet();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF0000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFD4AF85)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: userAvatar.isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(userAvatar),
                  )
                      : const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _drawerItem('About Tingungu', Icons.info_outline),
                _drawerItem('Media', Icons.play_circle_outline),
                _drawerItem('Events', Icons.calendar_today),
                _drawerItem('Give', Icons.favorite_outline),
                _drawerItem('Settings', Icons.settings),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_profile');
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF85),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF85)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF85), Color(0xFFC19A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF85).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tingungu Wallet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingWallet
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'R ${walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                   final result = await Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => const TopUpWalletScreen(),
                     ),
                   );

                  // Reload wallet balance if top-up was successful
                  if (result == true) {
                    _loadWalletBalance();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD4AF85),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'TOP UP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Community page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CommunityScreen(),
              ),
            );
          } else if (index == 2) {
            // Media page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MediaScreen(),
              ),
            );
          } else if (index == 3) {
            // Events page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventsScreen(),
              ),
            );

          } else {
            // Home page
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFFD4AF85),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }

  void _showBuyBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFFAF9F6),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'What would you like to buy?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0000),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBuyOption(
                  title: 'Marketplace',
                  description: 'Buy goods and products from church members',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF5B8FA3),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildBuyOption(
                  title: 'Value Added Services',
                  description:
                  'Buy electricity, airtime, and other digital products',
                  icon: Icons.bolt_outlined,
                  color: const Color(0xFFD4AF85),
                  onTap: () {
                    Navigator.pop(context);
                    _showVASBottomSheet();
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVASBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFFAF9F6),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'What do you need?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0000),
                  ),
                ),
                const Text(
                  'Choose a service to purchase',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildVASOption(
                  title: 'Airtime',
                  description: 'Top up airtime for any network',
                  icon: Icons.phone_outlined,
                  color: const Color(0xFF5B8FA3),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyAirtimeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildVASOption(
                  title: 'Data',
                  description: 'Purchase data bundles',
                  icon: Icons.wifi_outlined,
                  color: const Color(0xFF6C9BA8),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Data Purchase'),
                        backgroundColor: Color(0xFF6C9BA8),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildVASOption(
                  title: 'Electricity',
                  description: 'Buy electricity tokens',
                  icon: Icons.bolt_outlined,
                  color: const Color(0xFFD4AF85),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Electricity Purchase'),
                        backgroundColor: Color(0xFFD4AF85),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildVASOption(
                  title: 'Voucher',
                  description: 'Purchase gift and scratch vouchers',
                  icon: Icons.card_giftcard_outlined,
                  color: const Color(0xFF8B7355),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Voucher Purchase'),
                        backgroundColor: Color(0xFF8B7355),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVASOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}