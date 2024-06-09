import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'package:todo_calendar_client/models/enums/EventType.dart';
import 'package:todo_calendar_client/models/enums/EventStatus.dart';
import 'dart:convert';

class EditExistingEventModel extends RequestWithToken {
  final int eventId;
  final String caption;
  final String description;
  final String start;
  final String duration;
  final String eventType;
  final String eventStatus;
  final List<int> guestIds;

  EditExistingEventModel(
      {required int userId,
      required String token,
      required this.eventId,
      required this.caption,
      required this.description,
      required this.start,
      required this.duration,
      required this.eventType,
      required this.eventStatus,
      this.guestIds = const []})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'event_id': eventId,
      'caption': caption,
      'description': description,
      'scheduled_start': start,
      'duration': duration,
      'event_type': eventType,
      'event_status': eventStatus,
      'guests_ids': guestIds
    };
  }
}
