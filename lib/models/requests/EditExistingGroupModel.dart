import 'package:todo_calendar_client/models/enums/GroupType.dart';
import 'package:todo_calendar_client/models/requests/AddNewGroupModel.dart';
import 'dart:convert';

class EditExistingGroupModel extends AddNewGroupModel {
  final int groupId;

  EditExistingGroupModel(
      {required int userId,
      required String token,
      required String groupName,
      required String groupType,
      List<int> participants = const [],
      required this.groupId})
      : super(
            userId: userId,
            token: token,
            groupName: groupName,
            groupType: groupType);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_id': groupId,
      'group_name': groupName,
      'group_type': groupType,
      'participants': participants
    };
  }
}
