import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/otp.dart';
import '../../services/api_service.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  File? _photoLivreur;
  File? _photoVehicule;
  String _role = 'client';
  bool _isLoading = false;
  final _imagePicker = ImagePicker();

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

  Future<void> _pickImage(bool isVehicle) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image != null) {
    setState(() {
          if (isVehicle) {
            _photoVehicule = File(image.path);
          } else {
            _photoLivreur = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection de l\'image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inscription',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF28C38),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFF28C38),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Créez votre compte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                      decoration: InputDecoration(
                  labelText: 'Nom',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFF28C38)),
                        ),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
                    const SizedBox(height: 15),
              TextFormField(
                controller: _prenomController,
                      decoration: InputDecoration(
                  labelText: 'Prénom',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFF28C38)),
                        ),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
                    const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                      decoration: InputDecoration(
                  labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFF28C38)),
                        ),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
                    const SizedBox(height: 15),
              TextFormField(
                controller: _telephoneController,
                      decoration: InputDecoration(
                  labelText: 'Téléphone',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFF28C38)),
                        ),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
                    const SizedBox(height: 15),
              TextFormField(
                controller: _motDePasseController,
                      decoration: InputDecoration(
                  labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFFF28C38)),
                        ),
                ),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.work_outline),
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
              ),
              if (_role == 'livreur') ...[
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF28C38).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations du livreur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF28C38),
                              ),
                            ),
                            const SizedBox(height: 15),
                TextFormField(
                  controller: _typeVehiculeController,
                              decoration: InputDecoration(
                    labelText: 'Type de véhicule',
                                prefixIcon: const Icon(Icons.directions_car_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Color(0xFFF28C38)),
                                ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                            const SizedBox(height: 15),
                TextFormField(
                  controller: _numeroImmatriculationController,
                              decoration: InputDecoration(
                    labelText: "Numéro d'immatriculation",
                                prefixIcon: const Icon(Icons.numbers_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Color(0xFFF28C38)),
                                ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Photo du livreur',
                                        style: TextStyle(
                                          color: Color(0xFFF28C38),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _pickImage(false),
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: const Color(0xFFF28C38)),
                                          ),
                                          child: _photoLivreur != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: Image.file(
                                                    _photoLivreur!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    color: Color(0xFFF28C38),
                                                    size: 40,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Photo du véhicule',
                                        style: TextStyle(
                                          color: Color(0xFFF28C38),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _pickImage(true),
                                        child: Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: const Color(0xFFF28C38)),
                                          ),
                                          child: _photoVehicule != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: Image.file(
                                                    _photoVehicule!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.directions_car,
                                                    color: Color(0xFFF28C38),
                                                    size: 40,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
                    const SizedBox(height: 30),
              _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF28C38)))
                        : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                                if (_role == 'livreur' &&
                                    (_photoLivreur == null || _photoVehicule == null)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Veuillez ajouter les photos requises',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                          setState(() => _isLoading = true);
                                final apiService =
                                    Provider.of<ApiService>(context, listen: false);
                          final OTPResponse response = await apiService.register(
                            nom: _nomController.text,
                            prenom: _prenomController.text,
                            email: _emailController.text,
                            telephone: _telephoneController.text,
                            motDePasse: _motDePasseController.text,
                            role: _role,
                                  typeVehicule: _role == 'livreur'
                                      ? _typeVehiculeController.text
                                      : null,
                                  numeroImmatriculation: _role == 'livreur'
                                      ? _numeroImmatriculationController.text
                                      : null,
                                  photoLivreur: _role == 'livreur'
                                      ? _photoLivreur?.path
                                      : null,
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
                                    SnackBar(
                                      content: Text(response.message),
                                      backgroundColor: Colors.red,
                                    ),
                            );
                          }
                        }
                      },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF28C38),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
            ],
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}