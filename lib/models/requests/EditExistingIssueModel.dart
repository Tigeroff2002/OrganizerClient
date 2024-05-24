import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/requests/AddNewIssueModel.dart';
import 'package:todo_calendar_client/models/requests/AddNewTaskModel.dart';
import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class EditExistingIssueModel extends AddNewIssueModel {

  final int issueId;
  final String issueStatus;

  EditExistingIssueModel({
    required int userId,
    required String token,
    required String issueType,
    required String title,
    required String description,
    required String imgLink,
    required this.issueId,
    required this.issueStatus
  })
      : super(
        userId: userId,
        token: token,
        issueType: issueType,
        title: title,
        description: description,
        imgLink: imgLink);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'issue_id': issueId,
      'issue_type': issueType,
      'title': title,
      'description': description,
      'img_link': imgLink,
      'issue_id': issueId,
      'issue_status': issueStatus
    };
  }

  String serialize() {
    return jsonEncode(toJson());
  }
}