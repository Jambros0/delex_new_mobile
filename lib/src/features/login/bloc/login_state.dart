import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String accessToken;
  final String refreshToken;
  const LoginSuccess({required this.accessToken, required this.refreshToken});
  @override
  List<Object> get props => [accessToken, refreshToken];
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure({required this.error});
  @override
  List<Object> get props => [error];
}
