import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _typeVehiculeController = TextEditingController();
  final _numeroImmatriculationController = TextEditingController();
  String _role = 'client';
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _typeVehiculeController.dispose();
    _numeroImmatriculationController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
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
                    'Inscription',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nomController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty || !value.contains('@') ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telephoneController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? '6 caractères minimum' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _role,
                    onChanged: (value) => setState(() => _role = value!),
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Client')),
                      DropdownMenuItem(value: 'livreur', child: Text('Livreur')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                  ),
                  if (_role == 'livreur') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeVehiculeController,
                      style: const TextStyle(color: Color(0xFF1C2526)),
                      decoration: InputDecoration(
                        labelText: 'Type de véhicule',
                        labelStyle: const TextStyle(color: Color(0xFF616161)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroImmatriculationController,
                      style: const TextStyle(color: Color(0xFF1C2526)),
                      decoration: InputDecoration(
                        labelText: 'Numéro d’immatriculation',
                        labelStyle: const TextStyle(color: Color(0xFF616161)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _isLoading
                      ? const SpinKitCircle(color: Color(0xFFF28C38), size: 40)
                      : CustomButton(
                          text: 'S’inscrire',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final apiService = Provider.of<ApiService>(context, listen: false);
                              bool success = await apiService.register(
                                nom: _nomController.text,
                                prenom: _prenomController.text,
                                email: _emailController.text,
                                telephone: _telephoneController.text,
                                motDePasse: _passwordController.text,
                                role: _role,
                                typeVehicule: _role == 'livreur' ? _typeVehiculeController.text : null,
                                numeroImmatriculation: _role == 'livreur'
                                    ? _numeroImmatriculationController.text
                                    : null,
                                photoLivreur: null,
                              );
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pushNamed(context, '/login');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Inscription échouée.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Déjà un compte ? Connectez-vous',
                      style: TextStyle(color: Color(0xFFF28C38), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}