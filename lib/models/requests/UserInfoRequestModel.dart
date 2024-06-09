import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class UserInfoRequestModel extends RequestWithToken {
  UserInfoRequestModel({
    required int userId,
    required String token,
  }) : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token};
  }
}
