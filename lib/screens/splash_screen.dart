import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      size: 120,
                      color: Color(0xFFF28C38),
                    ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bienvenue',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Continuez en tant que :',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Client',
                onPressed: () => Navigator.pushNamed(context, '/login'),
                width: 200,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Livreur',
                onPressed: () => Navigator.pushNamed(context, '/login'),
                width: 200,
                backgroundColor: Colors.blueGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}