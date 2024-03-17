import 'package:flutter/cupertino.dart';
import 'package:todo_calendar_client/models/requests/IssueInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/IssueInfoResponse.dart';

class FullIssueInfoResponse extends IssueInfoResponse {

  final String userName;

  FullIssueInfoResponse({
    required String issueType,
    required String title,
    required String description,
    required String imgLink,
    required String createMoment,
    required this.userName
  }) : super(
      issueType: issueType,
      title: title,
      description: description,
      imgLink: imgLink,
      createMoment: createMoment);

  factory FullIssueInfoResponse.fromJson(Map <String, dynamic> json) {
    return FullIssueInfoResponse(
      issueType: json['issue_type'],
      title: json['title'],
      description: json['description'],
      imgLink: json['img_link'],
      createMoment: json['issue_moment'],
      userName: json['user_name']
    );
  }
}