// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import 'dart:convert';

class SettingsProvider extends ChangeNotifier {
  List<ProfileModel> _profiles = [];
  ProfileModel _activeProfile = ProfileModel.defaultProfile();
  
  List<ProfileModel> get profiles => _profiles;
  ProfileModel get activeProfile => _activeProfile;
  
  // Getters de compatibilidad (para no romper código existente)
  int get updateInterval => _activeProfile.temperatureInterval;
  int get temperatureInterval => _activeProfile.temperatureInterval;
  int get airQualityInterval => _activeProfile.airQualityInterval;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar perfiles
    final profilesJson = prefs.getStringList('profiles') ?? [];
    if (profilesJson.isEmpty) {
      // Crear perfil por defecto si no hay ninguno
      _profiles = [ProfileModel.defaultProfile()];
      await _saveProfiles();
    } else {
      _profiles = profilesJson.map((json) => ProfileModel.fromJson(json)).toList();
    }
    
    // Cargar perfil activo
    final activeProfileId = prefs.getString('active_profile_id') ?? 'default';
    _activeProfile = _profiles.firstWhere(
      (p) => p.id == activeProfileId,
      orElse: () => _profiles.first,
    );
    
    notifyListeners();
  }
  
  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = _profiles.map((p) => p.toJson()).toList();
    await prefs.setStringList('profiles', profilesJson);
  }
  
  Future<void> _saveActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile_id', _activeProfile.id);
  }
  
  // Cambiar perfil activo
  Future<void> setActiveProfile(String profileId) async {
    final profile = _profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => _profiles.first,
    );
    _activeProfile = profile;
    await _saveActiveProfile();
    notifyListeners();
  }
  
  // Crear nuevo perfil
  Future<void> createProfile(ProfileModel profile) async {
    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
  }
  
  // Actualizar perfil existente
  Future<void> updateProfile(ProfileModel updatedProfile) async {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index != -1) {
      _profiles[index] = updatedProfile.copyWith(modifiedAt: DateTime.now());
      
      // Si es el perfil activo, actualizarlo también
      if (_activeProfile.id == updatedProfile.id) {
        _activeProfile = _profiles[index];
      }
      
      await _saveProfiles();
      notifyListeners();
    }
  }
  
  // Eliminar perfil
  Future<void> deleteProfile(String profileId) async {
    // No permitir eliminar el perfil por defecto
    if (profileId == 'default') return;
    
    // No permitir eliminar si es el único perfil
    if (_profiles.length <= 1) return;
    
    // Si se elimina el perfil activo, cambiar al primero disponible
    if (_activeProfile.id == profileId) {
      _activeProfile = _profiles.first.id == profileId ? _profiles[1] : _profiles.first;
      await _saveActiveProfile();
    }
    
    _profiles.removeWhere((p) => p.id == profileId);
    await _saveProfiles();
    notifyListeners();
  }
  
  // Compatibilidad con código antiguo
  Future<void> setUpdateInterval(int seconds) async {
    // Actualizar el intervalo del perfil activo para ambos componentes
    final updatedProfile = _activeProfile.copyWith(
      temperatureInterval: seconds,
      airQualityInterval: seconds,
    );
    await updateProfile(updatedProfile);
  }
}

