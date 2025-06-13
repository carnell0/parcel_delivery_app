import 'package:flutter/material.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _utilisateurData;
  bool _isLoading = true;
  bool _isSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUtilisateurData();
    _loadSectionState();
  }

  Future<void> _loadSectionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSectionExpanded = prefs.getBool('isSectionExpanded') ?? false;
    });
  }

  Future<void> _saveSectionState(bool expanded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSectionExpanded', expanded);
  }

  Future<void> _loadUtilisateurData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getCurrentUtilisateur();
      print('Profile Data: $data'); // Debug log
      setState(() {
        _utilisateurData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
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
      return const Center(
        child: SpinKitDoubleBounce(
          color: AppTheme.primaryColor,
          size: 50.0,
        ),
      );
    }

    print('Données actuelles: $_utilisateurData'); // Debug log
    final isDriver = _utilisateurData?['role'] == 'livreur';

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête du profil
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF757575).withOpacity(0.9),
                    const Color(0xFF9E9E9E).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF757575).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar avec icône de profil
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
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
                  // Informations utilisateur
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
            ),

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
    );
  }
}