import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/utilisateur/register_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/delivery/delivery_list_screen.dart';
import '../screens/delivery/delivery_details_screen.dart';
import '../screens/delivery/create_delivery_screen.dart';

class Routes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';

  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String deliveryList = '/deliveries';
  static const String deliveryDetails = '/delivery-details';
  static const String createDelivery = '/create-delivery';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Auth routes
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      otpVerification: (context) => OTPVerificationScreen(
        email: ModalRoute.of(context)!.settings.arguments as String,
      ),

      // Main routes
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      messages: (context) => const MessagesScreen(),
      deliveryList: (context) => const DeliveryListScreen(),
      deliveryDetails: (context) => DeliveryDetailsScreen(
        deliveryId: ModalRoute.of(context)!.settings.arguments as String,
      ),
      createDelivery: (context) => const CreateDeliveryScreen(),
    };
  }
} 