import 'dart:convert';

class UserRegisterModel {

  final String email;
  final String name;
  final String password;
  final String phoneNumber;
  final String firebaseToken;

  UserRegisterModel({
    required this.email,
    required this.name,
    required this.password,
    required this.phoneNumber,
    required this.firebaseToken
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'phone_number': phoneNumber,
      'firebase_token': firebaseToken
    };
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}