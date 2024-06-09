import 'dart:convert';

import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';

class TaskInfoResponse {
  final int taskId;
  final String caption;
  final String description;
  final String taskType;
  final String taskStatus;

  //final ShortUserInfoResponse reporter;
  //final ShortUserInfoResponse implementer;

  TaskInfoResponse({
    required this.taskId,
    required this.caption,
    required this.description,
    required this.taskType,
    required this.taskStatus,
    //required this.reporter,
    //required this.implementer
  });

  factory TaskInfoResponse.fromJson(Map<String, dynamic> json) {
    return TaskInfoResponse(
      taskId: json['task_id'],
      caption: json['caption'],
      description: json['description'],
      taskType: json['task_type'],
      taskStatus: json['task_status'],
      //reporter: json['reporter'],
      //implementer: json['implementer']
    );
  }
}
