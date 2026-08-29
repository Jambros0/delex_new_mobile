import 'package:equatable/equatable.dart';

abstract class LandingPageEvent extends Equatable {
  const LandingPageEvent();

  @override
  List<Object> get props => [];
}

class LoadLandingPage extends LandingPageEvent {}
