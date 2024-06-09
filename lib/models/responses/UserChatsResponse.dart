import 'dart:convert';

import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';

class UserChatsResponse {
  final List<dynamic> userChats;

  UserChatsResponse({required this.userChats});

  factory UserChatsResponse.fromJson(Map<String, dynamic> json) {
    return UserChatsResponse(userChats: json['chats']);
  }
}
