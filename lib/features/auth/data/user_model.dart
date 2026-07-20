import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? churchId;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.phone,
    this.email,
    this.photoUrl,
    this.churchId,
    required this.role,
    this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? phone,
    String? email,
    String? photoUrl,
    String? churchId,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      churchId: churchId ?? this.churchId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'churchId': churchId,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      displayName: map['displayName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      churchId: map['churchId'],
      role: map['role'] ?? 'member',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
