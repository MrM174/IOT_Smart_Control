// lib/screens/profiles_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/profile_model.dart';
import 'profile_edit_page.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Perfiles', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _createNewProfile(context),
            tooltip: 'Nuevo Perfil',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final profiles = settings.profiles;
              final activeProfile = settings.activeProfile;
              
              return Column(
                children: [
                  // Header info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2A2A3E).withOpacity(0.6),
                            const Color(0xFF1A1A2E).withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.manage_accounts_rounded, 
                            color: Theme.of(context).colorScheme.primary, 
                            size: 40
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Perfil Activo',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeProfile.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (activeProfile.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    activeProfile.description!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Lista de perfiles
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final isActive = profile.id == activeProfile.id;
                        
                        return _buildProfileCard(
                          context,
                          profile,
                          isActive,
                          settings,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ProfileModel profile,
    bool isActive,
    SettingsProvider settings,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ],
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF2A2A3E).withOpacity(0.4),
                  const Color(0xFF1A1A2E).withOpacity(0.4),
                ],
              ),
        border: Border.all(
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white.withOpacity(0.05),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isActive ? null : () => settings.setActiveProfile(profile.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'ACTIVO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _editProfile(context, profile),
                      tooltip: 'Editar',
                      color: Colors.white70,
                    ),
                    if (profile.id != 'default')
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () => _confirmDelete(context, profile, settings),
                        tooltip: 'Eliminar',
                        color: const Color(0xFFFF5252),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (profile.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.description!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildIntervalInfo(
                        icon: Icons.thermostat_rounded,
                        label: 'Temperatura',
                        seconds: profile.temperatureInterval,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIntervalInfo(
                        icon: Icons.air_rounded,
                        label: 'Aire',
                        seconds: profile.airQualityInterval,
                        color: const Color(0xFF4ECDC4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalInfo({
    required IconData icon,
    required String label,
    required int seconds,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${seconds}s',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );
  }

  void _editProfile(BuildContext context, ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(profile: profile),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileModel profile, SettingsProvider settings) {
    if (settings.profiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes eliminar el único perfil'),
          backgroundColor: Color(0xFFFF5252),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Perfil'),
        content: Text('¿Estás seguro de que quieres eliminar el perfil "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.deleteProfile(profile.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Perfil "${profile.name}" eliminado'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}


