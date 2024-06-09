import 'dart:convert';

import 'package:todo_calendar_client/models/enums/TaskCurrentStatus.dart';
import 'package:todo_calendar_client/models/enums/TaskType.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';

class ShortChatInfoResponse {
  final int chatId;
  final String caption;
  final int receiverId;
  final String receiverName;

  ShortChatInfoResponse(
      {required this.chatId,
      required this.caption,
      required this.receiverId,
      required this.receiverName});

  factory ShortChatInfoResponse.fromJson(Map<String, dynamic> json) {
    return ShortChatInfoResponse(
        chatId: json['chat_id'],
        caption: json['caption'],
        receiverId: json['receiver_id'],
        receiverName: json['receiver_name']);
  }
}
