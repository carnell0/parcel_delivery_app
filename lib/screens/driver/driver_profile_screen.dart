import 'package:flutter/material.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _utilisateurData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUtilisateurData();
  }

  Future<void> _loadUtilisateurData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getCurrentUtilisateur();
      setState(() {
        _utilisateurData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  Widget _buildProfileHeader() {
    final isDriver = _utilisateurData?['role'] == 'livreur';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.95),
            AppTheme.secondaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Infos utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom complet
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_utilisateurData?['nom'] ?? _utilisateurData?['last_name'] ?? ''} ${_utilisateurData?['prenom'] ?? _utilisateurData?['first_name'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _utilisateurData?['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Badge de rôle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDriver ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDriver ? Colors.green[200]! : Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDriver ? Icons.delivery_dining : Icons.shopping_bag,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDriver ? 'Livreur' : 'Client',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: textColor ?? Colors.grey[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor ?? Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
          backgroundColor: Color(0xFFF28C38),
        ),
        body: const Center(
          child: SpinKitDoubleBounce(
            color: AppTheme.primaryColor,
            size: 50.0,
          ),
        ),
      );
    }

    final isDriver = _utilisateurData?['role'] == 'livreur';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFFF28C38),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              // Options du profil
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.person_outline,
                      title: 'Modifier le profil',
                      onTap: () {
                        // TODO: Navigation vers la modification du profil
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.lock_outline,
                      title: 'Changer le mot de passe',
                      onTap: () {
                        // TODO: Navigation vers le changement de mot de passe
                      },
                    ),
                    if (isDriver) ...[
                      _buildDivider(),
                      _buildProfileOption(
                        icon: Icons.directions_car_outlined,
                        title: 'Véhicule',
                        onTap: () {
                          // TODO: Navigation vers les détails du véhicule
                        },
                      ),
                    ],
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.history,
                      title: 'Historique des livraisons',
                      onTap: () {
                        // TODO: Navigation vers l'historique
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      onTap: () {
                        // TODO: Navigation vers les paramètres
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'Aide et support',
                      onTap: () {
                        // TODO: Navigation vers l'aide
                      },
                    ),
                    _buildDivider(),
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'Déconnexion',
                      onTap: () async {
                        final apiService = Provider.of<ApiService>(context, listen: false);
                        await apiService.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
