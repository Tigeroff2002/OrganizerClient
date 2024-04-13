class CommonSnapshotInfoResponse {

  final String creationTime;
  final String beginMoment;
  final String endMoment;
  final String snapshotType;
  final String auditType;
  final String content;

  CommonSnapshotInfoResponse({
    required this.snapshotType,
    required this.auditType,
    required this.creationTime,
    required this.beginMoment,
    required this.endMoment,
    required this.content
  });

  factory CommonSnapshotInfoResponse.fromJson(Map <String, dynamic> json) {
    return CommonSnapshotInfoResponse(
        creationTime: json['creation_time'],
        beginMoment: json['begin_moment'],
        endMoment: json['end_moment'],
        snapshotType: json['snapshot_type'],
        auditType: json['audit_type'],
        content: json['content']
    );
  }
}