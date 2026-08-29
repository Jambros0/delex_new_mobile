import 'package:deex_bloc_mobile_app_dev/src/features/notification/data/models/notification_table_model.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotificationLoading extends NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationsInitial extends NotificationState {}

class NotificationsLoading extends NotificationState {
  final bool isLoadMore;

  NotificationsLoading({
    this.isLoadMore = false,
  });

  @override
  List<Object> get props => [
        isLoadMore,
      ];
}

class NotificationsLoaded extends NotificationState {
  final NotificationModel notificationModel;
  NotificationsLoaded({
    required this.notificationModel,
  });

  @override
  List<Object> get props => [
        notificationModel,
      ];
}

class NotificationError extends NotificationState {
  final String error;

  NotificationError(this.error);

  @override
  List<Object> get props => [error];
}
