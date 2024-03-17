import 'package:todo_calendar_client/models/enums/ReportType.dart';
import 'package:todo_calendar_client/models/requests/AddNewSnapshotModel.dart';
import 'dart:convert';
import 'RequestWithToken.dart';

class AddNewGroupSnapshotModel extends AddNewSnapshotModel {

  final int groupId;

  AddNewGroupSnapshotModel({
    required int userId,
    required String token,
    required String snapshotType,
    required String beginMoment,
    required String endMoment,
    required this.groupId
  })
    : super(
        userId: userId, 
        token: token, 
        snapshotType: snapshotType, 
        beginMoment: beginMoment, 
        endMoment: endMoment);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'snapshot_type': snapshotType,
      'begin_moment': beginMoment,
      'end_moment': endMoment
    };
  }
}