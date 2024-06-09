import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class EventInfoRequest extends RequestWithToken {
  final int eventId;

  EventInfoRequest(
      {required int userId, required String token, required this.eventId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'event_id': eventId};
  }
}
