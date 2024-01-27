class IssueInfoResponse {

  final String issueType;
  final String title;
  final String description;
  final String imgLink;
  final String createMoment;

  IssueInfoResponse({
    required this.issueType,
    required this.title,
    required this.description,
    required this.imgLink,
    required this.createMoment
  });

  factory IssueInfoResponse.fromJson(Map <String, dynamic> json) {
    return IssueInfoResponse(
      issueType: json['issue_type'],
      title: json['title'],
      description: json['description'],
      imgLink: json['img_link'],
      createMoment: json['issue_moment']
    );
  }
}