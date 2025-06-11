import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:parcel_delivery/screens/splash_screen.dart';
import 'package:parcel_delivery/screens/login_screen.dart';
import 'package:parcel_delivery/screens/user/register_screen.dart';
import 'package:parcel_delivery/screens/user/home_screen.dart';
import 'package:parcel_delivery/screens/user/track_screen.dart';

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
          '/track': (context) => const TrackScreen(),
        },
      ),
    ),
  );
}