import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'giving_page.dart';
import 'store_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'notices_screen.dart';
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
import '../components/chatbot_widget.dart';


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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && mounted) {
            final data = snapshot.data() ?? {};
            setState(() {
              walletBalance = (data['wallet_balance'] ?? 0.0).toDouble();
              _isLoadingWallet = false;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingWallet = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading wallet balance: $e');
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


  bool _profileCompleted = true;

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userData = doc.data() ?? {};
          if (mounted) {
            setState(() {
              userName = userData['displayname'] ?? 'Guest';
              userAvatar = userData['avatar'] ?? '';
              _profileCompleted = userData['profile_completed'] ?? false;
              _isLoadingProfile = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingProfile = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      if (kDebugMode) print('Error loading profile: $e');
      if (mounted) setState(() => _isLoadingProfile = false);
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB8B24)),
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
                    if (!_profileCompleted)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB8B24).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFB8B24)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFB8B24)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Please complete your profile.",
                                style: TextStyle(color: Color(0xFF3B0D11), fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())).then((_) => _loadUserProfile());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFB8B24),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Complete"),
                            ),
                          ],
                        ),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ChatbotWidget(),
          );
        },
        backgroundColor: const Color(0xFF3B0D11),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
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
              child: const Icon(Icons.menu, color: Color(0xFFFB8B24)),
            ),
          ),
          const Text(
            'Tingungu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B0D11),
            ),
          ),

          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticesScreen())),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notices').snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Badge(
                    label: Text(count.toString()),
                    isLabelVisible: count > 0,
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFFB8B24),
                    ),
                  );
                }
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B0D11),
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
              color: const Color(0xFFFB8B24).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB8B24)),
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
            color: const Color(0xFFFB8B24).withOpacity(0.15),
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
                  color: const Color(0xFFFB8B24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Scripture',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFB8B24),
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
              color: Color(0xFF3B0D11),
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
                  color: Color(0xFFFB8B24),
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
            color: Color(0xFF3B0D11),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMarketplaceCard(
                icon: Icons.shopping_cart_outlined,
                label: 'Buy',
                color: const Color(0xFFFB8B24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMarketplaceCard(
                icon: Icons.local_offer_outlined,
                label: 'Sell',
                color: const Color(0xFFFB8B24),
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
                color: Color(0xFF3B0D11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFAF9F6),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF3B0D11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: userAvatar.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(userAvatar),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Tingungu Member',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem('Edit Profile', Icons.person_outline),
                _drawerItem('About Tingungu', Icons.info_outline),
                _drawerItem('Give', Icons.favorite_outline),
                _drawerItem('My Cart', Icons.shopping_cart_outlined),
                _drawerItem('Transactions', Icons.history),
                _drawerItem('Settings', Icons.settings),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Giving Options', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _seedGivingOptions();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notification_add_outlined, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Notices', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _seedNotices();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_collection_outlined, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Media Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _seedMediaData();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.data_saver_on, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Marketplace Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _seedMarketplaceData();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const Text(
                  'Developer: Jaspa Software',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Media', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedMediaData(); },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Notices', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedNotices(); },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Giving', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedGivingOptions(); },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Marketplace', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedMarketplaceData(); },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Events', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedEventsData(); },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Color(0xFFFB8B24)),
                  title: const Text('Seed Societies', style: TextStyle(fontSize: 14)),
                  onTap: () { Navigator.pop(context); _seedSocietiesData(); },
                ),
                const SizedBox(height: 12),
                SizedBox(
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
                      backgroundColor: const Color(0xFFFB8B24),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFB8B24)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Edit Profile') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        } else if (title == 'About Tingungu') {
          launchUrl(Uri.parse('https://www.tingungu.co.za/index.html'), mode: LaunchMode.externalApplication);
        } else if (title == 'Give') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GivingPage()));
        } else if (title == 'My Cart') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen(showCart: true)));
        } else if (title == 'Transactions') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        }
      },
    );
  }

  Widget _buildWalletCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B0D11),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B0D11).withOpacity(0.3),
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
                  foregroundColor: const Color(0xFF3B0D11),
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
        selectedItemColor: const Color(0xFFFB8B24),
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





  Future<void> _seedMediaData() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final batch = FirebaseFirestore.instance.batch();
    final videos = [
      {
        "title": "Sunday Morning Live Service",
        "url": "https://www.youtube.com/live/rlx4qHn9wkY",
        "thumbnail": "https://img.youtube.com/vi/rlx4qHn9wkY/0.jpg",
        "description": "Join our weekly Sunday service live stream for a powerful word and worship.",
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "Worship & Praise Session",
        "url": "https://www.youtube.com/live/NTTN8Ie15AY",
        "thumbnail": "https://img.youtube.com/vi/NTTN8Ie15AY/0.jpg",
        "description": "An uplifting session of praise and worship with the Tingungu choir.",
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "Midweek Fellowship Live",
        "url": "https://www.youtube.com/live/WhiwV1sp1aY",
        "thumbnail": "https://img.youtube.com/vi/WhiwV1sp1aY/0.jpg",
        "description": "Connecting mid-week for spiritual encouragement and community prayer.",
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "Tingungu TV: Youth Ministry",
        "url": "https://www.youtube.com/live/n2BMTvSIXkU",
        "thumbnail": "https://img.youtube.com/vi/n2BMTvSIXkU/0.jpg",
        "description": "Engaging our youth with relevant messages and dynamic worship.",
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "Evening Prayer with Pastor",
        "url": "https://www.youtube.com/live/-2jsw9JKhEQ",
        "thumbnail": "https://img.youtube.com/vi/-2jsw9JKhEQ/0.jpg",
        "description": "Closing the day with prayer and a short reflection from our leadership.",
        "createdAt": FieldValue.serverTimestamp()
      },
    ];
    for (var v in videos) {
      final docRef = FirebaseFirestore.instance.collection('media').doc();
      batch.set(docRef, v);
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 5 videos!')));
    }
  }

  Future<void> _seedNotices() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final batch = FirebaseFirestore.instance.batch();
    final notices = [
      {"title": "Sunday Service", "message": "Join us this Sunday at 9 AM for a special worship service.", "createdAt": FieldValue.serverTimestamp()},
      {"title": "Youth Meeting", "message": "Youth meeting will take place on Saturday at 2 PM.", "createdAt": FieldValue.serverTimestamp()},
      {"title": "Church Renovations", "message": "The church building project is starting next week. Thank you for your pledges!", "createdAt": FieldValue.serverTimestamp()},
    ];
    for (var n in notices) {
      final docRef = FirebaseFirestore.instance.collection('notices').doc();
      batch.set(docRef, n);
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 3 notices!')));
    }
  }

  Future<void> _seedGivingOptions() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final options = [
      {"name": "Tithes"},
      {"name": "Pledge for Church Building"},
      {"name": "Generous Donations"},
      {"name": "Pledge for Instruments"},
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (var opt in options) {
      final docRef = FirebaseFirestore.instance.collection('giving_options').doc();
      batch.set(docRef, opt);
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 4 giving options!')));
    }
  }

  Future<void> _seedMarketplaceData() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final products = [
      {"name": "Bible - KJV", "price": 150},
      {"name": "Bible - Xhosa", "price": 180},
      {"name": "Song Book", "price": 80},
      {"name": "Sunday Hat", "price": 120},
      {"name": "Church T-Shirt", "price": 200},
      {"name": "Branded Cup", "price": 50},
      {"name": "Worship CD", "price": 100},
      {"name": "Prayer Journal", "price": 60},
      {"name": "Church Pin", "price": 20},
      {"name": "Umbrella", "price": 90},
      {"name": "Scarf", "price": 70},
      {"name": "Wristband", "price": 25},
      {"name": "Necklace", "price": 40},
      {"name": "Offering Envelope", "price": 15},
      {"name": "Church Flag", "price": 130},
      {"name": "Backpack", "price": 250},
      {"name": "Notebook", "price": 35},
      {"name": "Sermon USB", "price": 90},
      {"name": "Bookmark", "price": 10},
      {"name": "Worship Hoodie", "price": 300},
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (var p in products) {
      final docRef = FirebaseFirestore.instance.collection('products').doc();
      batch.set(docRef, p);
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 20 products!')));
    }
  }

  Future<void> _seedEventsData() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final events = [
      {"month": "January", "date_start": "1", "date_end": null, "description": "New Year's Day", "venue": null},
      {"month": "January", "date_start": "1", "date_end": "28", "description": "Feb Connexional Children & Youth Back to School Campaign", "venue": "All Districts"},
      {"month": "January", "date_start": "7", "date_end": null, "description": "MCO Opens", "venue": null},
      {"month": "January", "date_start": "11", "date_end": null, "description": "Induction of Rev David Gertze by the Vice Chair", "venue": "Magalies Circuit"},
      {"month": "January", "date_start": "11", "date_end": null, "description": "Induction of Rev Moeletsi Sebolai and Thuso Manamela by the Bishop", "venue": "Ga Rankuwa"},
      {"month": "January", "date_start": "12", "date_end": "13", "description": "EMMU General Committee", "venue": "eMseni"},
      {"month": "January", "date_start": "12", "date_end": "13", "description": "Bishops Orientation", "venue": null},
      {"month": "January", "date_start": "13", "date_end": null, "description": "Limpopo District Trust Property", "venue": "Virtual"},
      {"month": "January", "date_start": "14", "date_end": null, "description": "Limpopo District EMMU Meeting", "venue": "Virtual"},
      {"month": "January", "date_start": "14", "date_end": "16", "description": "Bishops' Retreat", "venue": "TBC"},
      {"month": "January", "date_start": "15", "date_end": null, "description": "Limpopo District Finance Committee", "venue": "Virtual"},
      {"month": "January", "date_start": "16", "date_end": "18", "description": "Lay President & District Lay Leaders' Consultation", "venue": "Namibia District"},
      {"month": "January", "date_start": "17", "date_end": null, "description": "Connexional Women's Fellowship Spiritual opening Retreat", "venue": "NFSL District"},
      {"month": "January", "date_start": "18", "date_end": null, "description": "Induction of Rev Mosiga Seekoei by the Bishop", "venue": "Mbombela"},
      {"month": "January", "date_start": "19", "date_end": "23", "description": "Probationer Seminar", "venue": "eMseni"},
      {"month": "January", "date_start": "19", "date_end": "23", "description": "Order of Evangelism Probationer Seminar", "venue": "eMseni"},
      {"month": "January", "date_start": "20", "date_end": null, "description": "Synergizing the Orders", "venue": "Virtual"},
      {"month": "January", "date_start": "23", "date_end": null, "description": "Methodist Joint Removals (MJR) Meeting", "venue": "MCO"},
      {"month": "January", "date_start": "23", "date_end": "25", "description": "Connexional Women's Fellowship Executive Committee Meeting", "venue": "Lumko Retreat Centre"},
      {"month": "January", "date_start": "24", "date_end": null, "description": "Limpopo District Wesley Guild GEC", "venue": "Virtual"},
      {"month": "January", "date_start": "25", "date_end": null, "description": "Induction of Rev Elisha Moeketsi by the Bishop", "venue": "Mabieskraal"},
      {"month": "January", "date_start": "25", "date_end": null, "description": "Induction of Rev Gavin Felix by the Vice Chair", "venue": "Middleburg"},
      {"month": "January", "date_start": "25", "date_end": null, "description": "Seth Mokitimi Methodist Seminary Opening Service", "venue": "SMMS"},
      {"month": "January", "date_start": "27", "date_end": null, "description": "Limpopo District Management", "venue": "Virtual"},
      {"month": "January", "date_start": "27", "date_end": "29", "description": "Molopo District Boundaries Conversation: 27th Francistown, 28th Gaborone, 29th Mahikeng", "venue": "Molopo District"},
      {"month": "January", "date_start": "28", "date_end": null, "description": "Church Unity Commission Executive", "venue": "Virtual"},
      {"month": "January", "date_start": "29", "date_end": null, "description": "Connexional Men's League District Presidents Meeting", "venue": "Virtual"},
      {"month": "January", "date_start": "31", "date_end": null, "description": "Connexional Children and Youth Executive Meeting", "venue": "Virtual"},
      {"month": "February", "date_start": "3", "date_end": null, "description": "Connexional Unit Leaders' Meeting", "venue": "MCO"},
      {"month": "February", "date_start": "3", "date_end": "4", "description": "DEWCOM Meeting", "venue": "eMseni"},
      {"month": "February", "date_start": "5", "date_end": null, "description": "Local Preachers' Department District Secretaries Consultation", "venue": "Virtual"},
      {"month": "February", "date_start": "5", "date_end": null, "description": "MCSA Church Funds Investment & Advisory Committee", "venue": "TBA"},
      {"month": "February", "date_start": "5", "date_end": null, "description": "Communications Board Meeting", "venue": "MCO"},
      {"month": "February", "date_start": "6", "date_end": "8", "description": "Connexional Children and Youth Children's Ministry Indaba", "venue": "Lesotho"},
      {"month": "February", "date_start": "7", "date_end": null, "description": "Boundaries Sub-Committee: Molopo Conversations", "venue": "Rustenburg"},
      {"month": "February", "date_start": "7", "date_end": null, "description": "Limpopo District Women's Fellowship Extended Leaders Capacity Building Workshop", "venue": "Coalfields"},
      {"month": "February", "date_start": "8", "date_end": null, "description": "Induction of Revs Petrus Madumo and Monare", "venue": "Coalfields"},
      {"month": "February", "date_start": "8", "date_end": null, "description": "Induction of Revs Nomvula and Zamuxolo Botha by the Vice Chair", "venue": "Pretoria Central"},
      {"month": "February", "date_start": "9", "date_end": "13", "description": "Ordinands' Seminar", "venue": "Lumko Retreat Centre"},
      {"month": "February", "date_start": "10", "date_end": null, "description": "Connexional Audit Committee Meeting", "venue": null},
      {"month": "February", "date_start": "10", "date_end": null, "description": "Limpopo Circuit Steward's Consultative Workshop", "venue": "Virtual"},
      {"month": "February", "date_start": "10", "date_end": null, "description": "Mission Unit Advisory Board Meeting", "venue": "MCO"},
      {"month": "February", "date_start": "10", "date_end": null, "description": "MJR Coordinators' Workshop", "venue": "TBA"},
      {"month": "February", "date_start": "10", "date_end": "12", "description": "Limpopo District Minister's retreat", "venue": "TBA"},
      {"month": "February", "date_start": "11", "date_end": null, "description": "Ecumenical Affairs Advisory Board", "venue": "MCO"},
      {"month": "February", "date_start": "12", "date_end": null, "description": "Lay Training Advisory Panel Consultation", "venue": "Virtual"},
      {"month": "February", "date_start": "12", "date_end": null, "description": "Connexional Trust Property Committee", "venue": "Virtual"},
      {"month": "February", "date_start": "12", "date_end": "14", "description": "Young Men's Guild Connexional General Executive Committee Meeting", "venue": "Natal Coastal District"},
      {"month": "February", "date_start": "13", "date_end": "16", "description": "Women's Manyano Connexional Extended Executive Meeting", "venue": "NFSL District"},
      {"month": "February", "date_start": "13", "date_end": null, "description": "Wesley Guild Connexional General Executive Meeting", "venue": "Virtual"},
      {"month": "February", "date_start": "15", "date_end": null, "description": "Induction of Rev Sethunya Motlhodi by the Bishop", "venue": "Mphahlele"},
      {"month": "February", "date_start": "18", "date_end": null, "description": "Ash Wednesday", "venue": null},
      {"month": "February", "date_start": "19", "date_end": "20", "description": "Connexional Heritage Standing Committee", "venue": "TBC"},
      {"month": "February", "date_start": "19", "date_end": "21", "description": "Local Preachers Association General Committee Meeting", "venue": "Highveld & eSwatini District"},
      {"month": "February", "date_start": "20", "date_end": "22", "description": "Limpopo District Children Ministry Indaba & MCYU Opening Service (Sunday)", "venue": "Hoffenhein Lodge"},
      {"month": "February", "date_start": "22", "date_end": null, "description": "Induction of Rev Tshepo Nkosi by the Bishop", "venue": "Moreleta"},
      {"month": "February", "date_start": "24", "date_end": null, "description": "Medical Aid Committee", "venue": "MCO"},
      {"month": "February", "date_start": "24", "date_end": "25", "description": "Order of Evangelism Coordinators Consultation", "venue": "Emseni"},
      {"month": "February", "date_start": "26", "date_end": null, "description": "Finance Unit Investment and Advisory", "venue": "Virtual"},
      {"month": "February", "date_start": "26", "date_end": "March 1", "description": "Connexional Women's Fellowship General Executive Committee Meeting", "venue": "Central District [Maranatha]"},
      {"month": "February", "date_start": "27", "date_end": null, "description": "Connexional MethSSoc Executive Assembly", "venue": "Virtual"},
      {"month": "February", "date_start": "27", "date_end": "March 1", "description": "Limpopo Minister's Wives retreat", "venue": "TBA"},
      {"month": "February", "date_start": "27", "date_end": "March 1", "description": "Limpopo District Music Association Annual Convention", "venue": "Mabopane"},
      {"month": "February", "date_start": "28", "date_end": null, "description": "Limpopo District Young Women's Manyano DEC", "venue": "Seshego"},
      {"month": "February", "date_start": "28", "date_end": "March 1", "description": "Limpopo District YAM Strategic session & YAM Mhluzi Circuit Launch", "venue": "Mhluzi Circuit"},
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (var ev in events) {
      final docRef = FirebaseFirestore.instance.collection('events').doc();
      batch.set(docRef, {
        ...ev,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 65 events!')));
    }
  }

  Future<void> _seedSocietiesData() async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    final societies = [
      {"name": "Zion Society", "circuit": "Pretoria Central", "location": "Pretoria", "leader": "Rev. Smith"},
      {"name": "Ebenezer Society", "circuit": "Johannesburg East", "location": "Bedfordview", "leader": "Rev. Ndlovu"},
      {"name": "Central Methodist", "circuit": "Cape Town Central", "location": "Cape Town", "leader": "Rev. Botha"},
      {"name": "Bethel Society", "circuit": "Durban Coastal", "location": "Durban", "leader": "Rev. Gwala"},
      {"name": "Wesley Society", "circuit": "Port Elizabeth South", "location": "Gqeberha", "leader": "Rev. Jacobs"},
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (var s in societies) {
      final docRef = FirebaseFirestore.instance.collection('societies').doc();
      batch.set(docRef, {
        ...s,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded 5 societies!')));
    }
  }

  void _showBuyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFFAF9F6),
      builder: (context) => SingleChildScrollView(
        child: Column(
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
                    color: Color(0xFF3B0D11),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBuyOption(
                  title: 'Marketplace',
                  description: 'Buy goods and products from church members',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFFFB8B24),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen()));
                  },
                ),
                const SizedBox(height: 12),
                _buildBuyOption(
                  title: 'Value Added Services',
                  description:
                  'Buy electricity, airtime, and other digital products',
                  icon: Icons.bolt_outlined,
                  color: const Color(0xFFFB8B24),
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
      ),
    );
  }

  void _showVASBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: const Color(0xFFFAF9F6),
      builder: (context) => SingleChildScrollView(
        child: Column(
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
                    color: Color(0xFF3B0D11),
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
                  color: const Color(0xFFFB8B24),
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
                  color: const Color(0xFFFB8B24),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Data Purchase'),
                        backgroundColor: Color(0xFFFB8B24),
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
                  color: const Color(0xFFFB8B24),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Electricity Purchase'),
                        backgroundColor: Color(0xFFFB8B24),
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
                  color: const Color(0xFFFB8B24),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Voucher Purchase'),
                        backgroundColor: Color(0xFFFB8B24),
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
                      color: Color(0xFF3B0D11),
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
                      color: Color(0xFF3B0D11),
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