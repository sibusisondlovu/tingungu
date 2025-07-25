import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _isLastPage = index == 3);
                },
                children: const [
                  _OnboardPage(
                    image: 'assets/images/logo.png',
                    title: 'Welcome to Tingungu',
                    description:
                    'Your church companion app – connect with your society, stay informed, and access spiritual support.',
                  ),
                  _OnboardPage(
                    image: 'assets/images/bill.png',
                    title: 'Buy & Pay Easily',
                    description:
                    'Buy airtime, pay electricity bills, send vouchers and much more right inside the app.',
                  ),
                  _OnboardPage(
                    image: 'assets/images/notify.png',
                    title: 'Stay Updated',
                    description:
                    'Get instant notifications for church announcements, events, and society notices.',
                  ),
                  _OnboardPage(
                    image: 'assets/images/giving.png',
                    title: 'Secure Giving',
                    description:
                    'Give your tithes, offerings, and pledges in a few taps with trusted channels.',
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: const WormEffect(
                activeDotColor: Colors.deepPurple,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            const SizedBox(height: 20),
            _isLastPage
                ? ElevatedButton(
              onPressed: _finishOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Get Started'),
            )
                : TextButton(
              onPressed: () {
                _controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 200),
        const SizedBox(height: 30),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 16),
        Text(description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
