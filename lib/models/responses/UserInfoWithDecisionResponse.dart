import 'dart:convert';

import 'package:todo_calendar_client/models/enums/DecisionType.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';

class UserInfoWithDecisionResponse extends ShortUserInfoResponse{

  final DecisionType decisionType;

  UserInfoWithDecisionResponse({
    required int userId,
    required String userName,
    required String userEmail,
    required String userRole,
    required String phoneNumber,
    required this.decisionType
  })
    : super(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userRole: userRole,
      phoneNumber: phoneNumber
    );

  factory UserInfoWithDecisionResponse.fromJson(Map <String, dynamic> json) {
    return UserInfoWithDecisionResponse(
        userId: json['user_id'],
        userName: json['user_name'],
        userEmail: json['user_email'],
        userRole: json['user_role'],
        phoneNumber: json['phone_number'],
        decisionType: json['decision_type']
    );
  }
}