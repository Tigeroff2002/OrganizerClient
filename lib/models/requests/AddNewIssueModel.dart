import 'RequestWithToken.dart';

class AddNewIssueModel extends RequestWithToken {
  final String issueType;
  final String title;
  final String description;
  final String imgLink;

  AddNewIssueModel(
      {required int userId,
      required String token,
      required this.issueType,
      required this.title,
      required this.description,
      required this.imgLink})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'issue_type': issueType,
      'title': title,
      'description': description,
      'img_link': imgLink
    };
  }
}
