class ParticipantCalendarResponse {
  final List<dynamic> userEvents;

  ParticipantCalendarResponse({
    required this.userEvents,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_events': userEvents,
    };
  }

  factory ParticipantCalendarResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantCalendarResponse(userEvents: json['user_events']);
  }
}
