import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class UserDirectChatRequest extends RequestWithToken {
  final int receiverId;

  UserDirectChatRequest(
      {required int userId, required String token, required this.receiverId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'receiver_id': receiverId};
  }
}
