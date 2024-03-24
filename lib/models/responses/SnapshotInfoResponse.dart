import 'dart:ffi';

class SnapshotInfoResponse {

  final String creationTime;
  final String beginMoment;
  final String endMoment;
  final String snapshotType;
  final double KPI;
  final String content;

  SnapshotInfoResponse({
    required this.snapshotType,
    required this.creationTime,
    required this.beginMoment,
    required this.endMoment,
    required this.KPI,
    required this.content
  });

  factory SnapshotInfoResponse.fromJson(Map <String, dynamic> json) {
    return SnapshotInfoResponse(
        creationTime: json['create_moment'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        KPI: json['kpi'],
        content: json['content']
    );
  }
}