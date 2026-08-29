class UserValidatePassword {
  final String username;
  final String otp;
  final String password;
  UserValidatePassword(
      {required this.username, required this.otp, required this.password});

  Map<String, String> toJson() {
    return {
      'username': username,
      'password': password,
      'otp': otp,
    };
  }
}
