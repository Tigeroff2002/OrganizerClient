import 'dart:ffi';

import 'package:flutter/material.dart';

class GroupSnapshotInfoResponse {

  final String snapshotType;
  final String auditType;
  final String beginMoment;
  final String endMoment;
  final String createMoment;
  final int groupId;
  final List<dynamic> participantsKPIS;
  final double averageKPI;
  final String content;

  GroupSnapshotInfoResponse({
    required this.snapshotType,
    required this.auditType,
    required this.beginMoment,
    required this.endMoment,
    required this.createMoment,
    required this.groupId,
    required this.participantsKPIS,
    required this.averageKPI,
    required this.content
  });

    factory GroupSnapshotInfoResponse.fromJson(Map <String, dynamic> json) {
    return GroupSnapshotInfoResponse(
        createMoment: json['creation_time'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        auditType: json['audit_type'],
        groupId: json['group_id'],
        participantsKPIS: json['participants_kpis'],
        averageKPI: json['average_kpi'],
        content: json['content']
    );
  }
}