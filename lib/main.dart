import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Notifications/ScheduleDailyNotification.dart';
import 'package:flutter_application_1/screens/Notifications/firebase_options.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/screens/user_screens/splash_screen.dart';
import 'package:flutter_application_1/screens/Notifications/push_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_application_1/utility/common.dart';

final navigatorKey = GlobalKey<NavigatorState>();
List<DropdownMenuEntry<String>> allUnitNames = [];
// Function to listen to background changes
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Background notification received");
    // Handle notification action if needed
  }
}

// To handle notification on foreground on web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Ok"),
        ),
      ],
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AwesomeNotifications().isNotificationAllowed().then((value) => {
        if (!value)
          {AwesomeNotifications().requestPermissionToSendNotifications()}
      });

  await ScheduleDailyNotification.initializeAwesomeNotification();
  await ScheduleDailyNotification().scheduleAllNotification();

  await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
    ScheduleDailyNotification().onActionReceivedMethod(receivedAction);
  });

  // On background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

  PushNotifications.init();
  if (!kIsWeb) {
    PushNotifications.localNotiInit();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      if (kIsWeb) {
        showNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
        );
      } else {
        PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData,
        );
      }
    }
  });

  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    });
  }
  dataForUnitName;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fleet Feast',
      theme: appTheme,
      home: SplashScreen(),
      navigatorKey: navigatorKey,
    );
  }
}
