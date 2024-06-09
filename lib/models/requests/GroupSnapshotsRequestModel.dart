import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class GroupSnapshotsRequestModel extends RequestWithToken {
  final int groupId;

  GroupSnapshotsRequestModel(
      {required int userId, required String token, required this.groupId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'group_id': groupId};
  }
}
