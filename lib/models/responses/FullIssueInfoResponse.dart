import 'package:flutter/cupertino.dart';
import 'package:todo_calendar_client/models/requests/IssueInfoRequest.dart';
import 'package:todo_calendar_client/models/responses/IssueInfoResponse.dart';

class FullIssueInfoResponse extends IssueInfoResponse {
  final String userName;

  FullIssueInfoResponse(
      {required int issueId,
      required String issueType,
      required String issueStatus,
      required String title,
      required String description,
      required String imgLink,
      required String createMoment,
      required this.userName})
      : super(
            issueId: issueId,
            issueType: issueType,
            issueStatus: issueStatus,
            title: title,
            description: description,
            imgLink: imgLink,
            createMoment: createMoment);

  factory FullIssueInfoResponse.fromJson(Map<String, dynamic> json) {
    return FullIssueInfoResponse(
        issueId: json['issue_id'],
        issueType: json['issue_type'],
        issueStatus: json['issue_status'],
        title: json['title'],
        description: json['description'],
        imgLink: json['img_link'],
        createMoment: json['issue_moment'],
        userName: json['user_name']);
  }
}
