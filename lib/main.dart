import 'dart:developer';

import 'package:attendance_app/firebase_options.dart';
import 'package:attendance_app/start.dart';
import 'package:attendance_app/tasks/sub/sub_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('إشعار في الخلفية: ${message.notification?.title}');
}  


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.requestPermission();

    // استقبال الإشعارات والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'إشعار جديد';
      final body = message.notification?.body ?? '';

      log('وصل إشعار والتطبيق مفتوح: $title');

      // عرض AwesomeDialog
      if (navigatorKey.currentContext != null) {
        AwesomeDialog(
          context: navigatorKey.currentContext!,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          title: title,
          desc: body,
          btnOkOnPress: () {},
        ).show();
      }
    });

    // استقبال الإشعارات عند الضغط عليها والتطبيق في الخلفية أو مغلق
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('تم فتح التطبيق من إشعار: ${message.notification?.title}');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'المروج',
        theme: ThemeData(
          fontFamily: 'Cairo',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: OnboardingScreen(),
      ),
    );
  }
}
