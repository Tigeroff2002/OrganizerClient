import 'package:todo_calendar_client/models/enums/GroupType.dart';
import 'dart:convert';
import 'RequestWithToken.dart';

class AddNewGroupModel extends RequestWithToken {
  final String groupName;
  final String groupType;
  final List<int> participants;

  AddNewGroupModel(
      {required int userId,
      required String token,
      required this.groupName,
      required this.groupType,
      this.participants = const []})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_name': groupName,
      'group_type': groupType,
      'participants': participants
    };
  }
}
