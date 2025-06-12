import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification OTP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Un code de vérification a été envoyé à ${widget.email}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Code OTP',
                  labelStyle: TextStyle(color: Color(0xFF616161)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Vérifier',
                      onPressed: _verifyOTP,
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  final apiService = Provider.of<ApiService>(context, listen: false);
                  final response = await apiService.resendOTP(email: widget.email);
                  setState(() => _isLoading = false);
                  if (response.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Un nouveau code a été envoyé')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.message)),
                    );
                  }
                },
                child: const Text('Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.verifyOTP(
        email: widget.email,
        otp: _otpController.text,
      );
      setState(() => _isLoading = false);
      
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Vérification réussie')),
          );
          // Redirection vers la page de connexion
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false, // Supprime toutes les routes précédentes
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Erreur lors de la vérification')),
        );
      }
    }
  }
}