import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

import 'GroupRequestedInfo.dart';

class GroupGetResponse extends Response {
  final Object? requestedInfo;

  GroupGetResponse(
      {required bool result, String? outInfo, required this.requestedInfo})
      : super(result: result, outInfo: outInfo);

  factory GroupGetResponse.fromJson(Map<String, dynamic> json) {
    return GroupGetResponse(
        result: json['result'],
        outInfo: json['out_info'],
        requestedInfo: json['requested_info']);
  }
}
