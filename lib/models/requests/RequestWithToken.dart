import 'dart:convert';

class RequestWithToken {
  final int userId;
  final String token;

  RequestWithToken({required this.userId, required this.token});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token};
  }
}
