
import 'package:flutter/material.dart';

import '../screens/buy_airtime_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/store_screen.dart';
import '../splash.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    switch (settings.name) {
      case Splash.id:
        return _route(const Splash());

      case BuyAirtimeScreen.id:
        return _route(const BuyAirtimeScreen());

      case StoreScreen.id:
        return _route(const StoreScreen());

      case RegisterScreen.id:
        return _route(const RegisterScreen());

      case ProfilePage.id:
        return _route(const ProfilePage());

      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _route(Widget widget) =>
      MaterialPageRoute(builder: (context) => widget);

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Route not found'),
        ),
        body: Center(
          child: Text(
            'ROUTE \n\n$name\n\nNOT FOUND',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
