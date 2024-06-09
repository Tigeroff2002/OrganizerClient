import 'dart:convert';

import 'package:todo_calendar_client/models/enums/EventStatus.dart';
import 'package:todo_calendar_client/models/enums/EventType.dart';
import 'package:todo_calendar_client/models/responses/GroupInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/ShortUserInfoResponse.dart';
import 'package:todo_calendar_client/models/responses/UserInfoWithDecisionResponse.dart';

class EventInfoResponse {
  final int eventId;
  final String caption;
  final String description;
  final String start;
  final String duration;
  final String eventType;
  final String eventStatus;

  //final ShortUserInfoResponse manager;
  //final GroupInfoResponse group;
  //final List<UserInfoWithDecisionResponse> guests;

  EventInfoResponse({
    required this.eventId,
    required this.caption,
    required this.description,
    required this.start,
    required this.duration,
    required this.eventType,
    required this.eventStatus,
    //required this.manager,
    //required this.group,
    //required this.guests
  });

  factory EventInfoResponse.fromJson(Map<String, dynamic> json) {
    return EventInfoResponse(
      eventId: json['event_id'],
      caption: json['caption'],
      description: json['description'],
      start: json['scheduled_start'],
      duration: json['duration'],
      eventType: json['event_type'],
      eventStatus: json['event_status'],
      //manager: json['manager'],
      //group: json['group'],
      //guests: json['guests']
    );
  }
}
