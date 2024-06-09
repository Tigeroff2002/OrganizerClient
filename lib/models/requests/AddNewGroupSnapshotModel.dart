import 'package:todo_calendar_client/models/enums/SnapshotType.dart';
import 'package:todo_calendar_client/models/requests/AddNewSnapshotModel.dart';
import 'dart:convert';
import 'RequestWithToken.dart';

class AddNewGroupSnapshotModel extends AddNewSnapshotModel {
  final int groupId;

  AddNewGroupSnapshotModel(
      {required int userId,
      required String token,
      required String snapshotType,
      required String auditType,
      required String beginMoment,
      required String endMoment,
      required this.groupId})
      : super(
            userId: userId,
            token: token,
            snapshotType: snapshotType,
            auditType: auditType,
            beginMoment: beginMoment,
            endMoment: endMoment);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'group_id': groupId,
      'snapshot_type': snapshotType,
      'audit_type': auditType,
      'begin_moment': beginMoment,
      'end_moment': endMoment
    };
  }
}
