// // ignore_for_file: unused_import, prefer_const_constructors, equal_keys_in_map
//
// import 'dart:convert';
//
// import 'package:deex_bloc_mobile_app_dev/src/features/bluetooth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
//   configLoading();
// }
//
// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..loadingStyle = EasyLoadingStyle.dark
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.yellow
//     ..backgroundColor = Colors.green
//     ..indicatorColor = Colors.yellow
//     ..textColor = Colors.yellow
//     ..maskColor = Colors.blue.withOpacity(0.5)
//     ..userInteractions = false
//     ..dismissOnTap = false;
// }
//
// class MyApp extends StatefulWidget {
//   static final GlobalKey<NavigatorState> navigatorKey =
//   GlobalKey<NavigatorState>();
//
//   static const String name = 'Awesome Notifications - Example App';
//   static const Color mainColor = Colors.deepPurple;
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String initialRoute='/';
//   int? notification_count;
//   Future<dynamic> onSelectNotification(String? screen) async {
//     Navigator.pushNamed(context, '/notifications');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: initialRoute,
//       routes: {
//         '/': (context) => RFIDScannerPage(),
//       },
//       builder: EasyLoading.init(),
//     );
//   }
// }

import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/data/services/dashboard_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/device_sync_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/bloc/to_server_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/device_sync/data/services/device_sync_services.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/bloc/equipment_locator_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/screens/equipment_locator_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/bloc/ex_inspection_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/dropdown_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/ex_register_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/file_uploads_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/funtional_area_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/repository/inspection_checklist_repo.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/data/services/ex_inspection_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_inspections/ui/screens/ex_inspection.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/bloc/ex_register_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/services/ex_register_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/ui/screen/ex_register_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/ui/screens/forgot_password_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/forgot_password/ui/screens/new_password_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/bloc/location_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/services/location_service.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/ui/screens/functional_areas.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/home/screens/home.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/landing_page/ui/screens/landing_page_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/license_key_page/ui/screens/license_key_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/login/ui/screens/login_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/bloc/notification_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/notification/data/services/notification_service.dart';
import 'dart:async';
import 'package:deex_bloc_mobile_app_dev/src/features/profile/ui/screens/profile_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/signature_upload_page/ui/screens/upload_signature_screen.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/file_upload_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/network_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'firebase_options.dart';

import 'src/features/dashboard/bloc/dashboard_bloc.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await setupFlutterNotifications();
    showFlutterNotification(message);
  } catch (e) {}
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // NotificationSettings settings =
  //     await FirebaseMessaging.instance.requestPermission();
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  if (!kIsWeb) {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await setupFlutterNotifications();
  }

  if (!kIsWeb) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await dotenv.load(fileName: 'env.dev');
  await NetworkUtils().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final authUtils = AuthUtils();
  final isLicenseValidated = await authUtils.isLicenseValidated();
  final isLoggedIn = await authUtils.isSessionActive();
  final username = await authUtils.getUsername() ?? '';

  if (isLoggedIn) {
    try {
      final dropdownRepository = DropdownRepository();
      final checklistRepository = InspectionChecklistRepo();
      if (NetworkUtils().isNetworkAvailable) {
        await dropdownRepository
            .checkDailySync(() => ExInspectionService().getAllDropDwn());
        await checklistRepository.checkDailyChecklistSync(
            () => ExInspectionService().fetchInspectionChecklist());
      }
    } catch (e) {
      debugPrint('Sync check error in main: $e');
    }
  }

  final String initialRoute;
  if (!isLicenseValidated) {
    initialRoute = '/license';
  } else if (isLoggedIn) {
    initialRoute = '/home';
  } else {
    initialRoute = '/login';
  }

  timeago.setLocaleMessages('en', timeago.EnShortMessages());
  runApp(MyApp(
    initialRoute: initialRoute,
    username: username,
  ));
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.dark
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  final String username;

  const MyApp({super.key, required this.initialRoute, required this.username});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String? _token = "";
  String? initialMessage;
  // bool _resolved = false;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      FirebaseMessaging.instance.getToken().then((token) {
        if (mounted) {
          setState(() {
            // _token = token;
          });
        }
      }).catchError((e) {
        debugPrint("Failed to get Firebase token: $e");
        return null;
      });

      FirebaseMessaging.instance.getInitialMessage().then(
            (value) => setState(
              () {
                // _resolved = true;
                initialMessage = value?.data.toString();
              },
            ),
          );

      FirebaseMessaging.onMessage.listen(showFlutterNotification);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardBloc(
              dashboardService: DashboardServices(), authUtils: AuthUtils()),
        ),
        BlocProvider(
          create: (context) => ExRegisterBloc(
              exRegisterService: ExRegisterService(),
              authUtils: AuthUtils(),
              checklistRepo: InspectionChecklistRepo()),
        ),
        BlocProvider(
          create: (context) => LocationBloc(
              locationService: LocationService(), authUtils: AuthUtils()),
        ),
        BlocProvider(
          create: (context) => ExInspectionsBloc(
              exInspectionService: ExInspectionService(),
              commonServiceUtil: FileUploadUtil(),
              dropdownRepository: DropdownRepository(),
              functionalAreaRepo: FunctionalAreaRepository(),
              exregisterRepo: ExregisterRepo(),
              checklistRepo: InspectionChecklistRepo(),
              fileUploadRepo: FileUploadRepository()),
        ),
        BlocProvider(
          create: (context) => DeviceSyncBloc(
              deviceSyncServices: DeviceSyncServices(), authUtils: AuthUtils()),
        ),
        BlocProvider(
          create: (context) => ToServerBloc(
              exRegisterService: ExRegisterService(), authUtils: AuthUtils()),
        ),
        BlocProvider(
          create: (context) => EquipmentLocatorBloc(
              exRegisterService: ExRegisterService(), authUtils: AuthUtils()),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(
              notificationService: NotificationService(),
              authUtils: AuthUtils()),
        ),
      ],
      child: GetMaterialApp(
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        title: 'DelEx Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: widget.initialRoute,
        getPages: [
          GetPage(name: '/license', page: () => const LicenseKeyScreen()),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(
              name: '/forgot_password',
              page: () => const ForgotPasswordScreen()),
          GetPage(
              name: '/new_password_screen',
              page: () => const NewPasswordScreen()),
          GetPage(
              name: '/upload_signature',
              page: () => const UploadSignatureScreen()),
          GetPage(name: '/landing', page: () => const LandingScreen()),
          GetPage(
              name: '/exInspections',
              page: () => const ExInspectionScreen(fromExRegister: false)),
          GetPage(name: '/exRegister', page: () => const ExRegisterScreen()),
          GetPage(
              name: '/functionalArea',
              page: () => const FunctionalAreasScreen()),
          GetPage(name: '/dashboard', page: () => const DashboardScreen()),
          GetPage(
              name: '/equipmentLocator',
              page: () => const EquipmentLocatorScreen()),
          GetPage(name: '/profile', page: () => const ProfileScreen()),
        ],
      ),
    );
  }
}
