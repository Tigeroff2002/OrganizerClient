import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class ResponseWithToken extends Response{

  final int userId;
  final String? token;
  final String? firebaseToken;
  final String currentHost;

  ResponseWithToken({
    required bool result,
    String? outInfo,
    required this.userId,
    this.token,
    this.firebaseToken,
    required this.currentHost
  }) :super(result: result, outInfo: outInfo);

  factory ResponseWithToken.fromJson(Map <String, dynamic> json) {
    return ResponseWithToken(
        result: json['result'],
        outInfo: json['out_info'],
        userId: json['user_id'],
        token: json['token'],
        firebaseToken: json['firebase_token'],
        currentHost: json['current_host']
    );
  }

    Map<String, dynamic> toJson() {
      return {
        'result': result,
        'outinfo': outInfo,
        'user_id': userId,
        'token': token,
        'firebase_token': firebaseToken,
        'current_host': currentHost
    };
  }
}