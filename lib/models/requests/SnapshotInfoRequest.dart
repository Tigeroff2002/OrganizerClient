import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';
import 'dart:convert';

class SnapshotInfoRequest extends RequestWithToken {
  final int snapshotId;

  SnapshotInfoRequest(
      {required int userId, required String token, required this.snapshotId})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'token': token, 'snapshot_id': snapshotId};
  }
}
