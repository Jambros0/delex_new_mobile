class UserDetails {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String userRole;
  String signature;
  final String userName;
  final String password;
  final String accessToken;
  final String refreshToken;

  UserDetails({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userRole,
    required this.signature,
    required this.userName,
    required this.password,
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userRole': userRole,
      'signature': signature,
      'userName': userName,
      'password': password,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory UserDetails.fromJson(Map<String, dynamic> map) {
    return UserDetails(
      userId: map['userId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      userRole: map['userRole'],
      signature: map['signature'],
      userName: map['userName'],
      password: map['password'],
      accessToken: map['accessToken'],
      refreshToken: map['refreshToken'],
    );
  }
}
