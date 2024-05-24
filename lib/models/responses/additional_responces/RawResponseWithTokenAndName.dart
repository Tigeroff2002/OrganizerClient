import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class RawResponseWithTokenAndName extends Response{

  final int userId;
  final String? token;
  final String? firebaseToken;
  final String userName;

  RawResponseWithTokenAndName({
    required bool result,
    String? outInfo,
    required this.userId,
    this.token,
    this.firebaseToken,
    required this.userName
  }) :super(result: result, outInfo: outInfo);

  factory RawResponseWithTokenAndName.fromJson(Map <String, dynamic> json) {
    return RawResponseWithTokenAndName(
        result: json['result'],
        outInfo: json['out_info'],
        userId: json['user_id'],
        token: json['token'],
        firebaseToken: json['firebase_token'],
        userName: json['user_name']
    );
  }
}