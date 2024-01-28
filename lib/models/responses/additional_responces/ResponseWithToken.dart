import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class ResponseWithToken extends Response{

  final int userId;
  final String? token;
  final String? firebaseToken;

  ResponseWithToken({
    required bool result,
    String? outInfo,
    required this.userId,
    this.token,
    this.firebaseToken
  }) :super(result: result, outInfo: outInfo);

  factory ResponseWithToken.fromJson(Map <String, dynamic> json) {
    return ResponseWithToken(
        result: json['result'],
        outInfo: json['out_info'],
        userId: json['user_id'],
        token: json['token'],
        firebaseToken: json['firebase_token']
    );
  }
}