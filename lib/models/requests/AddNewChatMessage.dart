import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class AddNewChatMessage extends RequestWithToken{

  final String text;
  final int chatId;

  AddNewChatMessage({
    required int userId,
    required String token,
    required this.text,
    required this.chatId
  }) : super(userId: userId, token: token);

    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'text': text,
      'chat_id': chatId
    };
  }
}