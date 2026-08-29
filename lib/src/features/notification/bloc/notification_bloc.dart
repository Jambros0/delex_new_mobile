import 'dart:async';
import 'dart:convert';

import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_states.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/data/models/notification_table_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/data/services/notification_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  // final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils;

  NotificationBloc({required this.notificationService, required this.authUtils})
      : super(NotificationInitial()) {
    on<NotificationsInitEvent>(locationsInitEvent);
    on<NotificationsFetchNotification>(fetchNotificationApi);
    on<NotificationsPostNotification>(postTokenNotificationApi);
  }
  FutureOr<void> locationsInitEvent(
      NotificationsInitEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationInitial());
  }

  FutureOr<void> fetchNotificationApi(NotificationsFetchNotification event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      // bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (NetworkUtils().isNetworkAvailable) {
        final response = await notificationService.fetchNotification(
            loggedInUser: event.loggedInUser);
        if (response['status']) {
          final data = jsonDecode(response['data']);
          NotificationModel notificationModel =
              NotificationModel.fromJson(data);
          emit(NotificationsLoaded(notificationModel: notificationModel));
        } else {
          emit(NotificationError("No notifications available"));
        }
      } else {
        emit(NotificationError("No Network available"));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  FutureOr<void> postTokenNotificationApi(NotificationsPostNotification event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      // bool isApiFlag = dotenv.env['IS_API_FLAG'] == 'true';
      if (NetworkUtils().isNetworkAvailable) {
        await notificationService.postNotifcationToken(
          token: event.token,
        );
      } else {
        emit(NotificationError("No Network available"));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
