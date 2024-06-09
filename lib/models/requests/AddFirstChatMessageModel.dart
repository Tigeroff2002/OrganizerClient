import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class AddFirstChatMessageModel extends RequestWithToken {
  final String text;
  final int receiverId;

  AddFirstChatMessageModel(
      {required int userId,
      required String token,
      required this.text,
      required this.receiverId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'text': text,
      'receiver_id': receiverId
    };
  }
}
