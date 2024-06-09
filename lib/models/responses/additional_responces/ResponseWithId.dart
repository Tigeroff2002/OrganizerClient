import 'package:todo_calendar_client/models/responses/additional_responces/Response.dart';

class ResponseWithId extends Response {
  final int id;

  ResponseWithId(
      {required this.id, required bool result, required String? outInfo})
      : super(result: result, outInfo: outInfo);

  factory ResponseWithId.fromJson(Map<String, dynamic> json) {
    return ResponseWithId(
        id: json['id'], result: json['result'], outInfo: json['out_info']);
  }
}
