import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/otp.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _typeVehiculeController = TextEditingController();
  final _numeroImmatriculationController = TextEditingController();
  String? _photoLivreurPath;
  String _role = 'client';
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _motDePasseController.dispose();
    _typeVehiculeController.dispose();
    _numeroImmatriculationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
    setState(() {
      _photoLivreurPath = 'path/to/image.jpg'; // Temporary placeholder
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motDePasseController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(value: 'livreur', child: Text('Livreur')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),
              if (_role == 'livreur') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeVehiculeController,
                  decoration: const InputDecoration(
                    labelText: 'Type de véhicule',
                    labelStyle: TextStyle(color: Color(0xFF616161)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroImmatriculationController,
                  decoration: const InputDecoration(
                    labelText: "Numéro d'immatriculation",
                    labelStyle: TextStyle(color: Color(0xFF616161)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Ajouter une photo'),
                ),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: "S'inscrire",
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          final apiService = Provider.of<ApiService>(context, listen: false);
                          final OTPResponse response = await apiService.register(
                            nom: _nomController.text,
                            prenom: _prenomController.text,
                            email: _emailController.text,
                            telephone: _telephoneController.text,
                            motDePasse: _motDePasseController.text,
                            role: _role,
                            typeVehicule: _role == 'livreur' ? _typeVehiculeController.text : null,
                            numeroImmatriculation: _role == 'livreur' ? _numeroImmatriculationController.text : null,
                            photoLivreur: _role == 'livreur' ? _photoLivreurPath : null,
                          );
                          setState(() => _isLoading = false);
                          if (response.success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPVerificationScreen(
                                  email: response.email!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message)),
                            );
                          }
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}