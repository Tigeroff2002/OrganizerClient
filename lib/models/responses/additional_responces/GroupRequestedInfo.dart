import '../ShortUserInfoResponse.dart';

class GroupRequestedInfo {
  final List<ShortUserInfoResponse> participants;

  GroupRequestedInfo({required this.participants});

  factory GroupRequestedInfo.fromJson(Map<String, dynamic> json) {
    return GroupRequestedInfo(participants: json['participants']);
  }
}
