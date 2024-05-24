class SystemAlertsResponse {

  final List<dynamic> alerts;

    SystemAlertsResponse({
      required this.alerts
  });

  factory SystemAlertsResponse.fromJson(Map <String, dynamic> json) {
    return SystemAlertsResponse(
      alerts: json['alerts']
    );
  }
}