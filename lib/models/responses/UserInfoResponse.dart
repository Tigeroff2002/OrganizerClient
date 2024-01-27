import 'dart:convert';

import 'package:todo_calendar_client/models/responses/GroupInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/EventInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/TaskInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/SnapshotInfoResponse.dart';

class UserInfoResponse {

  final String userName;
  final String userEmail;
  final String password;
  final String phoneNumber;
  final List<dynamic> userGroups;
  final List<dynamic> userEvents;
  final List<dynamic> userTasks;
  final List<dynamic> userSnapshots;
  final List<dynamic> userIssues;

  UserInfoResponse({
    required this.userName,
    required this.userEmail,
    required this.password,
    required this.phoneNumber,
    required this.userGroups,
    required this.userEvents,
    required this.userTasks,
    required this.userSnapshots,
    required this.userIssues
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
      'user_email': userEmail,
      'phone_number': phoneNumber,
      'user_groups': userGroups,
      'user_tasks': userTasks,
      'user_events': userEvents,
      'user_snapshots': userSnapshots,
      'user_issues': userIssues
    };
  }

  factory UserInfoResponse.fromJson(Map <String, dynamic> json) {
    return UserInfoResponse(
        userName: json['user_name'],
        password: json['password'],
        userEmail: json['user_email'],
        phoneNumber: json['phone_number'],
        userGroups: json['user_groups'],
        userTasks: json['user_tasks'],
        userEvents: json['user_events'],
        userSnapshots: json['user_snapshots'],
        userIssues: json['user_issues']
    );
  }
}