import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class EditExistingMessageModel extends RequestWithToken {
  final String text;
  final int messageId;

  EditExistingMessageModel(
      {required int userId,
      required String token,
      required this.text,
      required this.messageId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'text': text,
      'message_id': messageId
    };
  }
}
