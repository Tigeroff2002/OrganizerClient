class UserEmailConfirmationExpiredModel {
  final String email;

  UserEmailConfirmationExpiredModel({required this.email});

  Map<String, dynamic> toJson() {
    return {"email": email};
  }
}
