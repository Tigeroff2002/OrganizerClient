import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'package:todo_calendar_client/models/enums/EventType.dart';
import 'package:todo_calendar_client/models/enums/EventStatus.dart';
import 'dart:convert';

class AddNewEventModel extends RequestWithToken {
  final String caption;
  final String description;
  final String start;
  final String duration;
  final String eventType;
  final String eventStatus;
  final int groupId;
  final List<int> guestIds;

  AddNewEventModel(
      {required int userId,
      required String token,
      required this.caption,
      required this.description,
      required this.start,
      required this.duration,
      required this.eventType,
      required this.eventStatus,
      this.groupId = 0,
      this.guestIds = const []})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'caption': caption,
      'description': description,
      'scheduled_start': start,
      'duration': duration,
      'event_type': eventType,
      'event_status': eventStatus,
      'group_id': groupId,
      'guests_ids': guestIds
    };
  }
}
