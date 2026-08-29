import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_login.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final UserLogin userLogin;
  const LoginButtonPressed({required this.userLogin});
  @override
  List<Object> get props => [userLogin];
}

class LogoutButtonPressed extends LoginEvent {
  final String userId;
  const LogoutButtonPressed({required this.userId});
  @override
  List<Object> get props => [userId];
}