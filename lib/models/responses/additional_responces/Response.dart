import 'dart:convert';

class Response {
  final bool result;
  final String? outInfo;

  Response({required this.result, this.outInfo});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(result: json['result'], outInfo: json['out_info']);
  }
}
