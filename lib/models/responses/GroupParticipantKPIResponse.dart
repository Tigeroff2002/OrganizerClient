class GroupParticipantKPIResponse {
  final int participantId;
  final String participantName;
  final double participantKPI;

  GroupParticipantKPIResponse(
      {required this.participantId,
      required this.participantName,
      required this.participantKPI});

  factory GroupParticipantKPIResponse.fromJson(Map<String, dynamic> json) {
    return GroupParticipantKPIResponse(
        participantId: json['participant_id'],
        participantName: json['participant_name'],
        participantKPI: json['participant_kpi']);
  }
}
