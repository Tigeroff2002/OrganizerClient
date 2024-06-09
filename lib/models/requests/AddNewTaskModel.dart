import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class AddNewTaskModel extends RequestWithToken {
  final String caption;
  final String description;
  final String taskType;
  final String taskStatus;
  final int implementerId;

  AddNewTaskModel(
      {required int userId,
      required String token,
      required this.caption,
      required this.description,
      required this.taskType,
      required this.taskStatus,
      required this.implementerId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'caption': caption,
      'description': description,
      'task_type': taskType,
      'task_status': taskStatus,
      'implementer_id': implementerId
    };
  }
}
