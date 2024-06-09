import 'package:todo_calendar_client/models/responses/UserInfoResponse.dart';

class UsersListResponse {
  final List<dynamic> users;

  UsersListResponse({required this.users});

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(users: json['users']);
  }
}
