class UserEmailConfirmationModel {

  final String email;
  final String code;

  UserEmailConfirmationModel({
    required this.email,
    required this.code
  });

  Map<String, dynamic> toJson(){
    return {
      "email": email,
      "code": code
    };
  }
}