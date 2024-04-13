class IssueInfoResponse {

  final int issueId;
  final String issueType;
  final String issueStatus;
  final String title;
  final String description;
  final String imgLink;
  final String createMoment;

  IssueInfoResponse({
    required this.issueId,
    required this.issueType,
    required this.issueStatus,
    required this.title,
    required this.description,
    required this.imgLink,
    required this.createMoment
  });

  factory IssueInfoResponse.fromJson(Map <String, dynamic> json) {
    return IssueInfoResponse(
      issueId: json['issue_id'],
      issueType: json['issue_type'],
      issueStatus: json['issue_status'],
      title: json['title'],
      description: json['description'],
      imgLink: json['img_link'],
      createMoment: json['issue_moment']
    );
  }
}