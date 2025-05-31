import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final user = apiService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.prenom ?? 'User'} ${user?.nom ?? ''}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user?.email ?? 'N/A'}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  apiService.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                backgroundColor: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}