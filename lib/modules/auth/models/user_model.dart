// lib/data/models/user_model.dart
class UserModel {
  final String? id;
  final String email;
  final String? fullName;
  final String? cefrLevel;
  final bool isOnboarded;

  UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.cefrLevel,
    required this.isOnboarded,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    fullName: json['fullName'],
    cefrLevel: json['cefrLevel'], // Trình độ ban đầu có thể null
    isOnboarded: json['isOnboarded'] ?? false, // Biến quan trọng để điều hướng
  );
}
