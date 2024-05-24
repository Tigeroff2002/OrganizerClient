import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class MessageInfoRequest extends RequestWithToken{

  final int messageId;

  MessageInfoRequest({
    required int userId,
    required String token,
    required this.messageId
  })
  : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'message_id': messageId
    };
  }
}