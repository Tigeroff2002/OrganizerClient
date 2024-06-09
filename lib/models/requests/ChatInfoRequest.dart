import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class ChatInfoRequest extends RequestWithToken {
  final int chatId;

  ChatInfoRequest(
      {required int userId, required String token, required this.chatId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'chat_id': chatId};
  }
}
