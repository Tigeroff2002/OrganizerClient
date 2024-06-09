import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class EditExistingTaskModel extends AddNewTaskModel {
  final int taskId;

  EditExistingTaskModel(
      {required int userId,
      required String token,
      required String caption,
      required String description,
      required String taskType,
      required String taskStatus,
      required int implementerId,
      required this.taskId})
      : super(
            userId: userId,
            token: token,
            caption: caption,
            description: description,
            taskType: taskType,
            taskStatus: taskStatus,
            implementerId: implementerId);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'task_id': taskId,
      'caption': caption,
      'description': description,
      'task_type': taskType,
      'task_status': taskStatus,
      'implementer_id': implementerId
    };
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}
