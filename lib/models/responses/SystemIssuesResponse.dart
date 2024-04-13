class SystemIssuesResponse {

  final List<dynamic> issues;

    SystemIssuesResponse({
      required this.issues
  });

  factory SystemIssuesResponse.fromJson(Map <String, dynamic> json) {
    return SystemIssuesResponse(
      issues: json['issues']
    );
  }
}