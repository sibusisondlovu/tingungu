
import 'package:flutter/material.dart';
import 'package:tingungu_app/screens/home_screen.dart';

import '../screens/buy_airtime_screen.dart';
import '../screens/giving_page.dart';
import '../screens/payfast_page.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/society_selection_screen.dart';
import '../screens/store_screen.dart';
import '../splash.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    switch (settings.name) {
      case Splash.id:
        return _route(const Splash());

      case HomeScreen.id:
        return _route(const HomeScreen());

      case BuyAirtimeScreen.id:
        return _route(const BuyAirtimeScreen());

      case StoreScreen.id:
        return _route(const StoreScreen());

      case RegisterScreen.id:
        return _route(const RegisterScreen());

      case ProfilePage.id:
        return _route(const ProfilePage());

      case SocietySelectionPage.id:
        return _route(SocietySelectionPage(currentSociety: args,));

      case GivingPage.id:
        return _route(const GivingPage());

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
