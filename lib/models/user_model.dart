import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String department;
  final String password;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.department,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      password: json['password'],
    );
  }

  // Add fromFirestore factory constructor
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      department: data['department'] ?? '',
      password: data['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'department': department,
      'password': password,
    };
  }
}
