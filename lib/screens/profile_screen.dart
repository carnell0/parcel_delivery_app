import 'package:flutter/material.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _utilisateurData;
  bool _isSectionExpanded = true; // Par défaut, la section est ouverte

  @override
  void initState() {
    super.initState();
    _loadUtilisateurData();
    _loadSectionState();
  }

  // Charger l'état de la section
  Future<void> _loadSectionState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSectionExpanded = prefs.getBool('profile_section_expanded') ?? true;
    });
  }

  // Sauvegarder l'état de la section
  Future<void> _saveSectionState(bool isExpanded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_section_expanded', isExpanded);
  }

  Future<void> _loadUtilisateurData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.getCurrentUtilisateur();
      print('Données utilisateur reçues: $response'); // Debug log
      setState(() {
        _utilisateurData = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du profil: $e'); // Debug log
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement du profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  // Avatar avec icône de profil
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nom complet
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_utilisateurData?['nom'] ?? ''} ${_utilisateurData?['prenom'] ?? ''}',
                style: const TextStyle(
                  fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Badge de rôle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDriver ? Colors.green[50] : Colors.blue[50],
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
                          size: 18,
                          color: isDriver ? Colors.green[700] : Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDriver ? 'Livreur' : 'Client',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDriver ? Colors.green[700] : Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informations supplémentaires pour les livreurs
                  if (isDriver) ...[
                    ExpansionTile(
                      initiallyExpanded: _isSectionExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isSectionExpanded = expanded;
                        });
                        _saveSectionState(expanded);
                      },
                      title: const Text(
                        'Informations du véhicule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.directions_car,
                                label: 'Véhicule',
                                value: _utilisateurData?['typeVehicule'] ?? 'Non spécifié',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                icon: Icons.confirmation_number,
                                label: 'Immatriculation',
                                value: _utilisateurData?['numeroImmatriculation'] ?? 'Non spécifié',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? Colors.grey[800],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.grey[800],
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
}