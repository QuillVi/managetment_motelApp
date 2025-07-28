import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uId;
  final String userName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final Timestamp createdAt;
  final String? fcmToken;

  UserModel({
    required this.uId,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    Timestamp? createdAt,
    this.fcmToken,
  }) : createdAt = createdAt ?? Timestamp.now();

  UserModel copyWith({
    String? uId,
    String? userName,
    String? fullName,
    String? email,
    String? phoneNumber,
    Timestamp? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      uId: uId ?? this.uId,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uId: doc.id,
      userName: data['userName'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'userName': userName,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
    };
  }
}
