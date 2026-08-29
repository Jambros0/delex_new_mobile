import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/bloc/landing_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/bloc/landing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingPageBloc extends Bloc<LandingPageEvent, LandingPageState> {
  LandingPageBloc() : super(LandingPageInitial()) {
    on<LoadLandingPage>((event, emit) {
      emit(LandingPageLoaded());
    });
  }
}
