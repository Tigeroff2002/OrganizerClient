import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class AdminsListRequestModel extends RequestWithToken {

  AdminsListRequestModel({
    required int userId,
    required String token
  })
  : super(userId: userId, token: token);

    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token
    };
  }
}