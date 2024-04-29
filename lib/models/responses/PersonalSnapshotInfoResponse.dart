import 'package:todo_calendar_client/models/responses/CommonSnapshotInfoResponse.dart';

class PersonalSnapshotInfoResponse extends CommonSnapshotInfoResponse {

  final double KPI;

  PersonalSnapshotInfoResponse({
    required int snapshotId,
    required String snapshotType,
    required String auditType,
    required String creationTime,
    required String beginMoment,
    required String endMoment,
    required this.KPI,
    required String content
  })
    : super(
      snapshotId: snapshotId,
      snapshotType: snapshotType,
      auditType: auditType,
      creationTime: creationTime,
      beginMoment: beginMoment,
      endMoment: endMoment,
      content: content);

  factory PersonalSnapshotInfoResponse.fromJson(Map <String, dynamic> json) {
    return PersonalSnapshotInfoResponse(
        snapshotId: json['snapshot_id'],
        creationTime: json['creation_time'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        auditType: json['audit_type'],
        KPI: json['kpi'],
        content: json['content']
    );
  }
}