import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    size: 80,
                    color: Color(0xFFF28C38),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accédez à vos livraisons',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFF1C2526)),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF616161)),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFF28C38)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Color(0xFF1C2526)),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: const TextStyle(color: Color(0xFF616161)),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFF28C38)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const SpinKitCircle(color: Color(0xFFF28C38), size: 40)
                    : CustomButton(
                        text: 'Se connecter',
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          final apiService = Provider.of<ApiService>(context, listen: false);
                          bool success = await apiService.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                          setState(() => _isLoading = false);
                          if (success) {
                            final route = apiService.user?.role == 'livreur'
                                ? '/driver/home'
                                : '/home';
                            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connexion échouée. Vérifiez vos identifiants.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Pas de compte ? Inscrivez-vous',
                    style: TextStyle(color: Color(0xFFF28C38), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}