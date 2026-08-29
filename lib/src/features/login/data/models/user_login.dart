class UserLogin {
  final String username;
  final String password;

  UserLogin({required this.username, required this.password});

  Map<String, String> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
