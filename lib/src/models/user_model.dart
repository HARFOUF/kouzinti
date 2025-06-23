import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role; // 'client' or 'chef'
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? address;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.profilePictureUrl,
    this.phoneNumber,
    this.address,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    // Backward compatibility: if only 'name' exists, split it
    String firstName = data['firstName'] ?? '';
    String lastName = data['lastName'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty && data['name'] != null) {
      final parts = (data['name'] as String).trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    return UserModel(
      id: documentId,
      firstName: firstName,
      lastName: lastName,
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
      profilePictureUrl: data['profilePictureUrl'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt,
    };
  }
} 