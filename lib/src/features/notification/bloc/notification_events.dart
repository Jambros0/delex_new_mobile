import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class NotificationsInitEvent extends NotificationEvent {}

class NotificationsFetchNotification extends NotificationEvent {
  final UserDetails? loggedInUser;
  NotificationsFetchNotification({this.loggedInUser});
}

class NotificationsPostNotification extends NotificationEvent {
  final dynamic token;
  final UserDetails? loggedInUser;
  NotificationsPostNotification({required this.token, this.loggedInUser});
}
