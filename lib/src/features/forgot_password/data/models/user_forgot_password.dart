class UserForgotPassword {
  final String username;
  UserForgotPassword({required this.username});

  Map<String, String> toJson() {
    return {
      'username': username,
    };
  }
}
