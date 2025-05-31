import 'package:flutter/material.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int? colisId = ModalRoute.of(context)?.settings.arguments as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi Colis #${colisId ?? ""}'),
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
        child: const Center(
          child: Text(
            'Carte de suivi (À intégrer avec flutter_map)',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}