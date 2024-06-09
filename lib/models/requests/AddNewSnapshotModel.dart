import 'package:todo_calendar_client/models/enums/SnapshotType.dart';
import 'dart:convert';
import 'RequestWithToken.dart';

class AddNewSnapshotModel extends RequestWithToken {
  final String snapshotType;
  final String auditType;
  final String beginMoment;
  final String endMoment;

  AddNewSnapshotModel(
      {required int userId,
      required String token,
      required this.snapshotType,
      required this.auditType,
      required this.beginMoment,
      required this.endMoment})
      : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'snapshot_type': snapshotType,
      'audit_type': auditType,
      'begin_moment': beginMoment,
      'end_moment': endMoment
    };
  }
}
