import 'dart:convert';

import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class PreRegistrationResponse extends Response{

  final String registrationCase;

  PreRegistrationResponse({
    required bool result,
    String? outInfo,
    required this.registrationCase
  }) :super(result: result, outInfo: outInfo);

  factory PreRegistrationResponse.fromJson(Map <String, dynamic> json) {
    return PreRegistrationResponse(
        result: json['result'],
        outInfo: json['out_info'],
        registrationCase: json['case']
    );
  }
}