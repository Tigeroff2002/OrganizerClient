class UsersListResponse {

  final List<dynamic> users;

  UsersListResponse({required this.users});

    Map<String, dynamic> toJson() {
    return {
      'users': users
    };
  }
}