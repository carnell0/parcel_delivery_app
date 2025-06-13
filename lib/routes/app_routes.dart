import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/utilisateur/login_screen.dart';
import '../screens/utilisateur/register_screen.dart';
import '../screens/utilisateur/home_screen.dart';
import '../screens/utilisateur/delivery_form_screen.dart';
import '../screens/utilisateur/track_screen.dart';
import '../screens/utilisateur/deliveries_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/driver/driver_home_screen.dart';
import '../screens/driver/driver_order_details.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/utilisateur/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/utilisateur/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/utilisateur/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/driver/home':
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case '/driver/order':
        return MaterialPageRoute(
          builder: (_) => const DriverOrderDetailsScreen(),
          settings: settings,
        );
      case '/utilisateur/delivery-form':
        return MaterialPageRoute(builder: (_) => const DeliveryFormScreen());
      case '/utilisateur/track':
        return MaterialPageRoute(builder: (_) => const TrackScreen(), settings: settings);
      case '/utilisateur/deliveries':
        return MaterialPageRoute(builder: (_) => const DeliveriesScreen());
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route inconnue : ${settings.name}')),
          ),
        );
    }
  }
}