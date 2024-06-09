import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class GetResponse extends Response {
  final Object? requestedInfo;

  GetResponse(
      {required bool result, String? outInfo, required this.requestedInfo})
      : super(result: result, outInfo: outInfo);

  factory GetResponse.fromJson(Map<String, dynamic> json) {
    return GetResponse(
        result: json['result'],
        outInfo: json['out_info'],
        requestedInfo: json['requested_info']);
  }
}
