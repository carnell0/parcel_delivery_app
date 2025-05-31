import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/user/login_screen.dart';
import '../screens/user/register_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/delivery_form_screen.dart';
import '../screens/user/track_screen.dart';
import '../screens/user/deliveries_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/driver/driver_home_screen.dart';
import '../screens/driver/driver_order_details.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/driver/home':
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case '/driver/order':
        return MaterialPageRoute(
          builder: (_) => const DriverOrderDetailsScreen(),
          settings: settings,
        );
      case '/delivery-form':
        return MaterialPageRoute(builder: (_) => const DeliveryFormScreen());
      case '/track':
        return MaterialPageRoute(builder: (_) => const TrackScreen(), settings: settings);
      case '/deliveries':
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