import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'package:todo_calendar_client/models/requests/users_list_requests/AllUsersRequestModel.dart';

class AllGroupUsersRequestModel extends AllUsersRequestModel {
  final int groupId;

  AllGroupUsersRequestModel(
      {required int userId, required String token, required this.groupId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'group_id': groupId};
  }
}
