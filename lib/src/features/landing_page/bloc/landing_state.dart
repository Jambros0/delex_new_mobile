import 'package:equatable/equatable.dart';

abstract class LandingPageState extends Equatable {
  const LandingPageState();

  @override
  List<Object> get props => [];
}

class LandingPageInitial extends LandingPageState {}

class LandingPageLoaded extends LandingPageState {}
