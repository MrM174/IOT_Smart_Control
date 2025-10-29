// lib/models/profile_model.dart
import 'dart:convert';

class ProfileModel {
  final String id;
  final String name;
  final String? description;
  final int temperatureInterval; // segundos
  final int airQualityInterval; // segundos
  final DateTime createdAt;
  final DateTime? modifiedAt;
  
  ProfileModel({
    required this.id,
    required this.name,
    this.description,
    this.temperatureInterval = 8,
    this.airQualityInterval = 8,
    DateTime? createdAt,
    this.modifiedAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Perfil por defecto
  factory ProfileModel.defaultProfile() {
    return ProfileModel(
      id: 'default',
      name: 'Estándar',
      description: 'Perfil predeterminado',
      temperatureInterval: 8,
      airQualityInterval: 8,
    );
  }
  
  // Convertir a Map para guardar en SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'temperatureInterval': temperatureInterval,
      'airQualityInterval': airQualityInterval,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }
  
  // Crear desde Map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      temperatureInterval: map['temperatureInterval'] ?? 8,
      airQualityInterval: map['airQualityInterval'] ?? 8,
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: map['modifiedAt'] != null ? DateTime.parse(map['modifiedAt']) : null,
    );
  }
  
  // Convertir a JSON
  String toJson() => json.encode(toMap());
  
  // Crear desde JSON
  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source));
  
  // Copiar con modificaciones
  ProfileModel copyWith({
    String? id,
    String? name,
    String? description,
    int? temperatureInterval,
    int? airQualityInterval,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      temperatureInterval: temperatureInterval ?? this.temperatureInterval,
      airQualityInterval: airQualityInterval ?? this.airQualityInterval,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}


