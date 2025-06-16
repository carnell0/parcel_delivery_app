import 'package:flutter/material.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (response['success']) {
          final utilisateur = apiService.utilisateur;
          debugPrint('Role utilisateur: ${utilisateur?.role}');
          if (utilisateur != null && utilisateur.role == 'livreur') {
            Navigator.pushReplacementNamed(context, '/driver/home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          String errorMessage = response['message'] ?? 'Une erreur est survenue';
          Color backgroundColor = AppTheme.errorColor;

          // Customize error message based on error type
          switch (response['error']) {
            case 'no_internet':
              errorMessage = 'Pas de connexion Internet. Veuillez vérifier votre connexion.';
              break;
            case 'server_unreachable':
              errorMessage = 'Le serveur n\'est pas accessible. Veuillez réessayer plus tard.';
              break;
            case 'timeout':
              errorMessage = 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
              break;
            case 'connection_error':
              errorMessage = 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion.';
              break;
            case 'invalid_credentials':
              backgroundColor = Colors.orange;
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 5),
              action: response['error'] == 'no_internet' || response['error'] == 'server_unreachable'
                  ? SnackBarAction(
                      label: 'Réessayer',
                      onPressed: _login,
                      textColor: Colors.white,
                    )
                  : null,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo et titre
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.width * 0.4,
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            maxWidth: 200,
                            minHeight: 120,
                            maxHeight: 200,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        Text(
                          'Connexion',
                          style: AppTheme.headlineStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bienvenue ! \n'
                          'Connectez-vous pour continuer',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.secondaryColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Champs de formulaire
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.textFieldDecoration(
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      hint: 'Entrez votre email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: AppTheme.textFieldDecoration(
                      label: 'Mot de passe',
                      prefixIcon: Icons.lock_outline,
                      hint: 'Entrez votre mot de passe',
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.secondaryColor.withOpacity(0.5),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Lien "Mot de passe oublié"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implémenter la réinitialisation du mot de passe
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 24),
                  // Lien d'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.secondaryColor.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'S\'inscrire',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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