import 'package:deex_bloc_mobile_app_dev/src/features/login/data/models/user_details.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_states.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  final String title;

  const NotificationScreen({super.key, required this.title});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Ex Register',
      'name': 'celiacmg, themateriel and 2 others',
      'time': '18m ago',
    },
    {
      'title': 'Ex Register',
      'name': 'matheus_herc, n8goodman and 2 others',
      'time': '22m ago',
    },
    {
      'title': 'Ex Register',
      'name': 'flutter_dev, dart_master and 1 other',
      'time': '30m ago',
    },
  ];
  final DBHelper _dbHelper = DBHelper();
  UserDetails? loggedInUser;
  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
  }

  Future<void> _fetchLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await _dbHelper.getLoggedInUserByUserId(userId);
      setState(() {
        loggedInUser = user;
      });
      // if (user != null && (user.signature.isEmpty)) {
      BlocProvider.of<NotificationBloc>(
        context,
      ).add(NotificationsFetchNotification(loggedInUser: loggedInUser));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NotificationsLoaded) {
          return Padding(
            padding: const EdgeInsets.only(top: 1, left: 300, bottom: 140),
            child: Center(
              child: Container(
                width: 530,
                height: 380,
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C002B5C),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x0C002B5C),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(context),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state
                                .notificationModel
                                .data
                                .notifications
                                .length,
                            itemBuilder: (context, index) {
                              final item = state
                                  .notificationModel
                                  .data
                                  .notifications[index];
                              final receivedAt = DateTime.tryParse(
                                item.createdAt.toString(),
                              );

                              final relativeTime = receivedAt != null
                                  ? timeago.format(
                                      receivedAt,
                                      locale: 'en',
                                      allowFromNow: false,
                                    )
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCBE3FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // CircleAvatar(
                                          //   radius: 15,
                                          //   backgroundColor: Colors.grey[300],
                                          //   backgroundImage: const AssetImage(
                                          //     'lib/src/features/notification/asset/delex_logo.png',
                                          //   ),
                                          // ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 10.0,
                                              right: 4,
                                              top: 2,
                                              bottom: 2,
                                            ),
                                            child: Image(
                                              width: 40,
                                              height: 30,
                                              image: AssetImage(
                                                'lib/src/features/notification/asset/delex_logo.png',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Text(
                                              '${relativeTime.replaceAll('~', '')} ago',
                                              style: const TextStyle(
                                                color: Colors.black26,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              child: Text(
                                                '${item.message}.',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 1, left: 300, bottom: 140),
            child: Center(
              child: Container(
                width: 530,
                height: 380,
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C002B5C),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x0C002B5C),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(context),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No notifications available',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x28002B5C),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.inter(
              color: const Color(0xFF1B2029),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'lib/src/features/device_sync/assets/Close.svg',
              width: 25,
              height: 25,
            ),
          ),
        ],
      ),
    );
  }
}
