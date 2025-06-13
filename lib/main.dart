import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:parcel_delivery/screens/splash_screen.dart';
import 'package:parcel_delivery/screens/login_screen.dart';
import 'package:parcel_delivery/screens/utilisateur/register_screen.dart';
import 'package:parcel_delivery/screens/utilisateur/home_screen.dart';
import 'package:parcel_delivery/screens/utilisateur/track_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApiService(),
      child: MaterialApp(
        title: 'Dcoliv',
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/track': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final deliveryId = args?['deliveryId'] as int?;
            if (deliveryId == null) {
              return const Scaffold(
                body: Center(
                  child: Text('ID de livraison non spécifié'),
                ),
              );
            }
            return TrackScreen(deliveryId: deliveryId);
          },
        },
      ),
    ),
  );
}