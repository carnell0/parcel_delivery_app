import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _natureController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _poidsController = TextEditingController();
  final _adresseDepartController = TextEditingController();
  final _adresseDestinationController = TextEditingController();
  String _selectedMode = 'Standard';
  File? _photoColis;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _photoColis = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final success = await apiService.createDelivery(
          utilisateurId: 1, // TODO: Récupérer l'ID de l'utilisateur connecté
          natureColis: _natureController.text,
          dimensions: _dimensionsController.text,
          poids: double.tryParse(_poidsController.text),
          photoColis: _photoColis?.path,
          adresseDepart: _adresseDepartController.text,
          adresseDestination: _adresseDestinationController.text,
          modeLivraison: _selectedMode,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Livraison créée avec succès')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la création de la livraison')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle livraison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _natureController,
                decoration: const InputDecoration(
                  labelText: 'Nature du colis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la nature du colis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(
                  labelText: 'Dimensions (L x l x h)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les dimensions du colis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _poidsController,
                decoration: const InputDecoration(
                  labelText: 'Poids (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le poids du colis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseDepartController,
                decoration: const InputDecoration(
                  labelText: 'Adresse de départ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse de départ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseDestinationController,
                decoration: const InputDecoration(
                  labelText: 'Adresse de destination',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse de destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMode,
                decoration: const InputDecoration(
                  labelText: 'Mode de livraison',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Standard',
                    child: Text('Standard'),
                  ),
                  DropdownMenuItem(
                    value: 'Express',
                    child: Text('Express'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMode = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Ajouter une photo du colis'),
              ),
              if (_photoColis != null) ...[
                const SizedBox(height: 16),
                Image.file(
                  _photoColis!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Créer la livraison'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _natureController.dispose();
    _dimensionsController.dispose();
    _poidsController.dispose();
    _adresseDepartController.dispose();
    _adresseDestinationController.dispose();
    super.dispose();
  }
} 