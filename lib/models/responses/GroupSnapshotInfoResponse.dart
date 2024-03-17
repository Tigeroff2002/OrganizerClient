import 'dart:ffi';

import 'package:flutter/material.dart';

class GroupSnapshotInfoResponse {

  final String snapshotType;
  final String beginMoment;
  final String endMoment;
  final String createMoment;
  final int groupId;
  final List<dynamic> participantsKPIS;
  final Float averageKPI;
  final String content;

  GroupSnapshotInfoResponse({
    required this.snapshotType,
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
        createMoment: json['create_moment'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        groupId: json['group_id'],
        participantsKPIS: json['participants_kpis'],
        averageKPI: json['average_kpi'],
        content: json['content']
    );
  }
}