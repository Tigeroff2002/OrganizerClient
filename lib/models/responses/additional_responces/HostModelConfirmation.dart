import 'package:todo_calendar_client/models/responses/additional_responces/HostModel.dart';

class HostModelConfirmation extends HostModel {
  final String email;
  final String userName;
  final String password;
  final String phone;
  final String token;

  HostModelConfirmation(
      {required this.email,
      required this.userName,
      required this.password,
      required this.phone,
      required this.token,
      required String currentHost})
      : super(currentHost: currentHost);

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'user_name': userName,
      'password': password,
      'phone_number': phone,
      'firebase_token': token,
      'current_host': currentHost
    };
  }

  factory HostModelConfirmation.fromJson(Map<String, dynamic> json) {
    return HostModelConfirmation(
        email: json['email'],
        userName: json['user_name'],
        password: json['password'],
        phone: json['phone_number'],
        token: json['firebase_token'],
        currentHost: json['current_host']);
  }
}
