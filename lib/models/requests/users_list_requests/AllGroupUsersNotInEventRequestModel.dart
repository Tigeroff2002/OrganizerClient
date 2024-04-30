import 'package:todo_calendar_client/models/requests/users_list_requests/AllGroupUsersRequestModel.dart';

class AllGroupUsersNotInEventRequestModel extends AllGroupUsersRequestModel{

  final int eventId;

  AllGroupUsersNotInEventRequestModel({
    required int userId,
    required String token,
    required int groupId,
    required this.eventId
  })
  : super(userId: userId, token: token, groupId: groupId);

    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_id': groupId,
      'event_id': eventId
    };
  }
}