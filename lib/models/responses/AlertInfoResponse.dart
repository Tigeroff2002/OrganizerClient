class AlertInfoResponse {
  final int alertId;
  final String title;
  final String description;
  final String moment;
  final bool isAlerted;

  AlertInfoResponse(
      {required this.alertId,
      required this.title,
      required this.description,
      required this.moment,
      required this.isAlerted});

  factory AlertInfoResponse.fromJson(Map<String, dynamic> json) {
    return AlertInfoResponse(
        alertId: json['alert_id'],
        title: json['title'],
        description: json['description'],
        moment: json['moment'],
        isAlerted: json['is_alerted']);
  }
}
