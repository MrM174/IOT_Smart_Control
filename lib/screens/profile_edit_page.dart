// lib/screens/profile_edit_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/profile_model.dart';

class ProfileEditPage extends StatefulWidget {
  final ProfileModel? profile; // null = crear nuevo

  const ProfileEditPage({super.key, this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _temperatureInterval;
  late int _airQualityInterval;

  bool get isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _descriptionController = TextEditingController(text: widget.profile?.description ?? '');
    _temperatureInterval = widget.profile?.temperatureInterval ?? 8;
    _airQualityInterval = widget.profile?.airQualityInterval ?? 8;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Perfil' : 'Nuevo Perfil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveProfile,
            tooltip: 'Guardar',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica
                _buildSection(
                  title: 'Información General',
                  icon: Icons.info_outline_rounded,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Perfil',
                        hintText: 'Ej: Rápido, Ahorro, etc.',
                        prefixIcon: Icon(Icons.label_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (Opcional)',
                        hintText: 'Breve descripción del perfil',
                        prefixIcon: Icon(Icons.description_rounded),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Configuración de intervalos
                _buildSection(
                  title: 'Intervalos de Actualización',
                  icon: Icons.timer_outlined,
                  children: [
                    _buildIntervalSlider(
                      title: 'Monitor de Temperatura/Humedad',
                      icon: Icons.thermostat_rounded,
                      value: _temperatureInterval,
                      color: const Color(0xFFFF6B6B),
                      onChanged: (value) {
                        setState(() {
                          _temperatureInterval = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildIntervalSlider(
                      title: 'Monitor de Calidad del Aire',
                      icon: Icons.air_rounded,
                      value: _airQualityInterval,
                      color: const Color(0xFF4ECDC4),
                      onChanged: (value) {
                        setState(() {
                          _airQualityInterval = value;
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Presets rápidos
                _buildSection(
                  title: 'Presets Rápidos',
                  icon: Icons.flash_on_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildPresetButton(
                            label: 'Rápido',
                            subtitle: '3s',
                            onTap: () => _applyPreset(3),
                            color: const Color(0xFFFF5252),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPresetButton(
                            label: 'Normal',
                            subtitle: '8s',
                            onTap: () => _applyPreset(8),
                            color: const Color(0xFF4ECDC4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPresetButton(
                            label: 'Ahorro',
                            subtitle: '30s',
                            onTap: () => _applyPreset(30),
                            color: const Color(0xFFBB86FC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(isEditing ? 'Actualizar Perfil' : 'Crear Perfil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildIntervalSlider({
    required String title,
    required IconData icon,
    required int value,
    required Color color,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value seg',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.3),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: '$value seg',
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 seg', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('60 seg', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton({
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPreset(int seconds) {
    setState(() {
      _temperatureInterval = seconds;
      _airQualityInterval = seconds;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset aplicado: $seconds segundos para todos los sensores'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del perfil es obligatorio'),
          backgroundColor: Color(0xFFFF5252),
        ),
      );
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (isEditing) {
      // Actualizar perfil existente
      final updatedProfile = widget.profile!.copyWith(
        name: name,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        temperatureInterval: _temperatureInterval,
        airQualityInterval: _airQualityInterval,
      );
      settings.updateProfile(updatedProfile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil "$name" actualizado'),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );
    } else {
      // Crear nuevo perfil
      final newProfile = ProfileModel(
        id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        temperatureInterval: _temperatureInterval,
        airQualityInterval: _airQualityInterval,
      );
      settings.createProfile(newProfile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil "$name" creado'),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );
    }
    
    Navigator.pop(context);
  }
}


