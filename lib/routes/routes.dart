import 'package:borktok/auth/wrapper.dart';
import 'package:borktok/screens/Bookavetpage.dart';
import 'package:borktok/screens/lost%20nd%20found/FoundDogPage.dart';
import 'package:borktok/screens/lost%20nd%20found/LostDogPage.dart';
import 'package:borktok/screens/NgoPage.dart';
import 'package:borktok/screens/buy%20and%20sell/doglisting.dart';
import 'package:borktok/screens/login_screen.dart';
import 'package:borktok/screens/profile_screen.dart';
import 'package:borktok/screens/signup_screen.dart';
import 'package:borktok/screens/unknown_page.dart'; // Import the unknown page
import 'package:borktok/screens/vets_nearby.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/reels_screen.dart';
import '../screens/tinder_screen.dart';
import '../screens/buy and sell/BuySell.dart';
import '../screens/Community.dart';
import '../screens/store_screen.dart';
import '../screens/reports_screen.dart';

class Routes {
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String splash = '/splash';
  static const String main = '/main';
  static const String home = '/home';
  static const String reels = '/reels';
  static const String tinder = '/tinder';
  static const String guide = '/guide';
  static const String essentials = '/essentials';
  static const String store = '/store';
  static const String report = '/report';
  static const String profile = '/profile';
  static const String dogListings = '/dogListings';
  static const String bookavet = '/bookavet';
  static const String lost = '/lost';
  static const String found = '/found';
  static const String ngopage = '/ngopage';
  static const String vetsnearby = '/vetsnearby';
  static const String unknown = '/unknown'; // Added unknown route constant

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication routes
      case authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      // Existing routes
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case vetsnearby:
        return MaterialPageRoute(builder: (_) => const VetsNearby());
      case home:
        // When navigating to home, prevent going back to previous screens
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: RouteSettings(name: settings.name, arguments: settings.arguments),
        );
      case reels:
        return MaterialPageRoute(builder: (context) => const ReelsScreen());
      case tinder:
        return MaterialPageRoute(builder: (context) => const TinderScreen());
      case guide:
        return MaterialPageRoute(builder: (context) => const BuySell());
      case profile:
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      case lost:
        return MaterialPageRoute(builder: (context) => const LostDogPage());
      case found:
        return MaterialPageRoute(builder: (context) => const FoundDogPage());
      case essentials:
        return MaterialPageRoute(builder: (context) => const Community());
      case store:
        return MaterialPageRoute(builder: (context) => const StoreScreen());
      case bookavet:
        return MaterialPageRoute(builder: (context) => const Bookavetpage());
      case report:
        return MaterialPageRoute(builder: (context) => const ReportsScreen());
      case ngopage:
        return MaterialPageRoute(builder: (context) => const NgoPage());
      case dogListings:
        return MaterialPageRoute(builder: (_) => const DogListingsScreen());
      case unknown:
        return MaterialPageRoute(builder: (_) => const UnknownPage());

      default:
        // Return the unknown page with the route name that was attempted
        return MaterialPageRoute(
          builder: (_) => UnknownPage(routeName: settings.name),
        );
    }
  }
}