import 'package:todo_calendar_client/models/requests/RequestWithToken.dart';

class UserUpdateRoleRequest extends RequestWithToken{

  final String newRole;
  final String rootPassword;

  UserUpdateRoleRequest(
  {
      required int userId,
      required String token,
      required this.newRole,
      required this.rootPassword
  }) : super(userId: userId, token: token);

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'user_role': newRole,
      'root_password': rootPassword
    };
    }
}