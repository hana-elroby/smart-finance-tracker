// User Model - نموذج المستخدم
// Represents user data in the app

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double? monthlyBudget;
  final String? currency;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.dateOfBirth,
    required this.createdAt,
    this.lastLoginAt,
    this.monthlyBudget,
    this.currency = 'EGP',
  });

  // Copy with method
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? monthlyBudget,
    String? currency,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currency: currency ?? this.currency,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'monthlyBudget': monthlyBudget,
      'currency': currency,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'])
          : null,
      monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble(),
      currency: map['currency'] ?? 'EGP',
    );
  }

  // Get initials for avatar
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    final names = displayName!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName!.substring(0, 1).toUpperCase();
  }

  // Get first name
  String get firstName {
    if (displayName == null || displayName!.isEmpty) {
      return email.split('@')[0];
    }
    return displayName!.split(' ')[0];
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        dateOfBirth,
        createdAt,
        lastLoginAt,
        monthlyBudget,
        currency,
      ];
}
