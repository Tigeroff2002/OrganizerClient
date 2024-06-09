import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class IssueInfoRequest extends RequestWithToken {
  final int issueId;

  IssueInfoRequest(
      {required int userId, required String token, required this.issueId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'issue_id': issueId};
  }
}
