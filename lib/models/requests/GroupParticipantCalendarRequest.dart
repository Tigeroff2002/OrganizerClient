import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class GroupParticipantCalendarRequest extends RequestWithToken {
  final int groupId;
  final int participantId;

  GroupParticipantCalendarRequest(
      {required int userId,
      required String token,
      required this.groupId,
      required this.participantId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_id': groupId,
      'participant_id': participantId
    };
  }
}
