import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({super.key});

  @override
  DeliveryFormScreenState createState() => DeliveryFormScreenState();
}

class DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverEmailController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _deliveryType = 'standard';
  bool _isLoading = false;

  @override
  void dispose() {
    _receiverEmailController.dispose();
    _receiverNameController.dispose();
    _receiverAddressController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final utilisateur = apiService.utilisateur;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle livraison'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _receiverEmailController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Email du destinataire',
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
                    controller: _receiverNameController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Nom du destinataire',
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
                    controller: _receiverAddressController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Adresse du destinataire',
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
                    controller: _weightController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Poids (kg)',
                      labelStyle: const TextStyle(color: Color(0xFF616161)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null ? 'Poids invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                  DropdownButtonFormField<String>(
                    value: _deliveryType,
                    onChanged: (value) => setState(() => _deliveryType = value!),
                    items: const [
                      DropdownMenuItem(value: 'standard', child: Text('Standard')),
                      DropdownMenuItem(value: 'express', child: Text('Express')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Type de livraison',
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
                  const SizedBox(height: 24),
                  _isLoading
                      ? const SpinKitCircle(color: Color(0xFFF28C38), size: 40)
                      : CustomButton(
                          text: 'Créer livraison',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final success = await apiService.createOrder(
                                utilisateurId: utilisateur!.id,
                                natureColis: _descriptionController.text,
                                dimensions: _receiverAddressController.text,
                                poids: double.parse(_weightController.text),
                                photoColis: '',
                                adresseDepart: _receiverAddressController.text,
                                adresseDestination: _receiverAddressController.text,
                                modeLivraison: _deliveryType,
                              );
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pushReplacementNamed(context, '/utilisateur/deliveries');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Échec de la création.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
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