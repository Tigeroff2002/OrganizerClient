import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'package:todo_calendar_client/models/requests/users_list_requests/AllGroupUsersRequestModel.dart';

class AllNotGroupUsersRequestModel extends AllGroupUsersRequestModel {

  AllNotGroupUsersRequestModel({
    required int userId,
    required String token,
    required int groupId
  })
  : super(userId: userId, token: token, groupId: groupId);

    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_id': groupId
    };
  }
}