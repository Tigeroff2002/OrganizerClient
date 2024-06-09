import 'dart:convert';

import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class UserLogoutModel extends RequestWithToken {
  final String firebaseToken;

  UserLogoutModel(
      {required int userId, required String token, required this.firebaseToken})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'firebase_token': firebaseToken};
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}
