import 'package:flutter/material.dart';
import 'package:todo_calendar_client/models/responses/CommonSnapshotInfoResponse.dart';

class GroupSnapshotInfoResponse extends CommonSnapshotInfoResponse {
  final int groupId;
  final List<dynamic> participantsKPIS;
  final double averageKPI;

  GroupSnapshotInfoResponse(
      {required int snapshotId,
      required String snapshotType,
      required String auditType,
      required String beginMoment,
      required String endMoment,
      required String creationTime,
      required this.groupId,
      required this.participantsKPIS,
      required this.averageKPI,
      required String content})
      : super(
            snapshotId: snapshotId,
            snapshotType: snapshotType,
            auditType: auditType,
            creationTime: creationTime,
            beginMoment: beginMoment,
            endMoment: endMoment,
            content: content);

  factory GroupSnapshotInfoResponse.fromJson(Map<String, dynamic> json) {
    return GroupSnapshotInfoResponse(
        snapshotId: json['snapshot_id'],
        creationTime: json['creation_time'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        auditType: json['audit_type'],
        groupId: json['group_id'],
        participantsKPIS: json['participants_kpis'],
        averageKPI: json['average_kpi'],
        content: json['content']);
  }
}
