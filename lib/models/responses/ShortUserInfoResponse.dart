class ShortUserInfoResponse {

  final int userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final String phoneNumber;
  final String role;

  ShortUserInfoResponse({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.phoneNumber,
    required this.role
  });

  factory ShortUserInfoResponse.fromJson(Map <String, dynamic> json) {
    return ShortUserInfoResponse(
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userRole: json['user_role'],
      phoneNumber: json['phone_number'],
      role: json['user_role']
    );
  }
}