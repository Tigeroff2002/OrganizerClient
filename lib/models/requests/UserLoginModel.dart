import 'dart:convert';

class UserLoginModel {

  final String email;
  final String password;
  final String firebaseToken;

  UserLoginModel({
    required this.email,
    required this.password,
    required this.firebaseToken
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firebase_token': firebaseToken
    };
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}