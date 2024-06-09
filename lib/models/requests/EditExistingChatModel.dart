import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class EditExistingChatModel extends RequestWithToken {
  final String chatCaption;
  final int chatId;

  EditExistingChatModel(
      {required int userId,
      required String token,
      required this.chatId,
      required this.chatCaption})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'chat_id': chatId,
      'caption': chatCaption
    };
  }
}
