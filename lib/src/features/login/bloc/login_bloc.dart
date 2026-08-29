import 'package:deex_bloc_mobile_app_dev/src/features/login/data/repository/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final tokens = await authRepository.authenticate(event.userLogin);
        emit(LoginSuccess(
          accessToken: tokens['accessToken']!,
          refreshToken: tokens['refreshToken']!,
        ));
      } catch (error) {
        emit(LoginFailure(error: error.toString()));
      }
    });

    on<LogoutButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        await authRepository.logout(event.userId);
        emit(LoginInitial());
      } catch (error) {
        emit(LoginFailure(error: error.toString()));
      }
    });
  }
}
