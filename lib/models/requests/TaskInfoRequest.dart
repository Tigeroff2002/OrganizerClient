import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class TaskInfoRequest extends RequestWithToken {
  final int taskId;

  TaskInfoRequest(
      {required int userId, required String token, required this.taskId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'task_id': taskId};
  }
}
