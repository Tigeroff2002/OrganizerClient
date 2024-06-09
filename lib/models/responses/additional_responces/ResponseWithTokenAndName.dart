import 'package:todo_calendar_client/models/responses/additional_responces/ResponseWithToken.dart';

class ResponseWithTokenAndName extends ResponseWithToken {
  final String userName;

  ResponseWithTokenAndName(
      {required bool result,
      String? outInfo,
      required int userId,
      String? token,
      String? firebaseToken,
      required String currentHost,
      required this.userName})
      : super(
            result: result,
            outInfo: outInfo,
            userId: userId,
            token: token,
            firebaseToken: firebaseToken,
            currentHost: currentHost);

  factory ResponseWithTokenAndName.fromJson(Map<String, dynamic> json) {
    return ResponseWithTokenAndName(
        result: json['result'],
        outInfo: json['out_info'],
        userId: json['user_id'],
        token: json['token'],
        firebaseToken: json['firebase_token'],
        currentHost: json['current_host'],
        userName: json['user_name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'outinfo': outInfo,
      'user_id': userId,
      'token': token,
      'firebase_token': firebaseToken,
      'current_host': currentHost,
      'user_name': userName
    };
  }
}
