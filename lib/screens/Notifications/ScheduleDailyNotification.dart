// ignore_for_file: file_names
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/screens/user_screens/user_profile.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localstorage/localstorage.dart';

class ScheduleDailyNotification {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorage storage = LocalStorage('my_data');

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initializeAwesomeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        )
      ],
    );
  }

  Future<void> scheduleAllNotification() async {
    await AwesomeNotifications().cancelAll();

    final cron = Cron();
    cron.schedule(Schedule.parse('*/1 * * * *'),
        () async => {allAwesomeNotificationsinCron()});
  }

  Future<void> allLocalNotificationsinCron() async {
    print("Cron Job for Local Notifications.............");
    Map<String, dynamic> dailyMenus = await _fetchDailyMenusFromDatabase();

    await showSimpleNotification(
      title: 'Breakfast',
      body: dailyMenus['Breakfast'] ?? 'No data available',
      payload: "Indian Navy", // Assuming breakfast is at 8 AM
    );
  }

  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  Future<void> allAwesomeNotificationsinCron() async {
    print("Cron Job for Awesome Notifications.............");
    User? user = await fetchUserData();
    bool isUserNotPresent = false;

    DateTime? startDate = user?.fromDate; // dd-MM-yyyy format
    DateTime? endDate = user?.toDate;
    DateTime? lastDate = user?.lastDate;

    DateTime today = DateTime.now();

    if (startDate != null && endDate != null && lastDate != null) {
      if ((today.isAfter(startDate) || today.isAtSameMomentAs(startDate)) &&
          (today.isBefore(endDate) || today.isAtSameMomentAs(endDate)) &&
          today.isAfter(lastDate)) {
        isUserNotPresent = true;
      }
    }

    if (user == null) {
      print("Pleaseeeeeeeeeeeeee Logineeeeeeee.............");
    } else if (isUserNotPresent) {
      print(
          'Current date is between start date and end date. USER not present');
    } else {
      Map<String, dynamic> dailyMenus = await _fetchDailyMenusFromDatabase();
      Map<String, String?> documentid = <String, String?>{
        'document_id': dailyMenus['document_id'],
        'tomorrow_document_id': dailyMenus['tomorrow_document_id']
      };

      documentid['meal_title'] = "breakfast";
      if (dailyMenus['breakfast_response'] != null &&
          dailyMenus['breakfast_response']) {
        await scheduleNotification(
          title: '☕ BREAKFAST alert! Not joining us? tap "No"',
          body: dailyMenus['Breakfast'] ?? 'No data available',
          documentId: documentid,
          hour: 8, // Assuming breakfast is at 8 AM
        );
      }

      documentid['meal_title'] = "Lunch";
      if (dailyMenus['lunch_response'] != null &&
          dailyMenus['lunch_response']) {
        await scheduleNotification(
          title: '🍚 LUNCH alert! Not joining us? tap "No"',
          body: dailyMenus['Lunch'] ?? 'No data available',
          documentId: documentid,
          hour: 12, // Assuming lunch is at 12 PM
        );
      }

      documentid['meal_title'] = "dinner";
      if (dailyMenus['dinner_response'] != null &&
          dailyMenus['dinner_response']) {
        await scheduleNotification(
          title: '🍴 DINNER alert! Not joining us? tap "No"',
          body: dailyMenus['Dinner'] ?? 'No data available',
          documentId: documentid,
          hour: 18, // Assuming dinner is at 6 PM
        );
      }
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Map<String, String?>? documentId,
    required int hour,
  }) async {
    Random random = Random();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: random.nextInt(1000) + 1,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: documentId,
        category: NotificationCategory.Event,
        wakeUpScreen: true,
        fullScreenIntent: true,
        backgroundColor: const Color.fromARGB(0, 231, 119, 21),
      ),
      schedule: NotificationCalendar(
        //hour: hour,
        //minute: 0,
        second: hour,
        millisecond: 0,
        preciseAlarm: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      ),
      actionButtons: [
        NotificationActionButton(
          key: "close",
          label: "No",
          autoDismissible: true,
          color: const Color.fromARGB(0, 216, 37, 37),
        ),
        NotificationActionButton(
          key: "veg",
          label: "Veg",
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: "nonveg",
          label: "Non-Veg",
          autoDismissible: true,
        ),
      ],
    );
  }

  Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    String button = receivedAction.buttonKeyPressed;

    if (button == 'close') {
      actionForNoButton(receivedAction);
    } else if (button == 'veg') {
      actionForVegButton(receivedAction);
    } else if (button == 'nonveg') {
      actionForNonVegButton(receivedAction);
    }
  }

  Future<void> actionForNoButton(ReceivedAction receivedAction) async {
    Map<String, String?>? documentId = receivedAction.payload;
    String? title = documentId?['meal_title'];

    User? user = await fetchUserData();
    String? preference = user?.preference;

    String docId = documentId?['document_id'] ?? "Not Found ID";
    String fieldCount = '${title!.toLowerCase()}_count';

    if (title.toLowerCase() == 'breakfast') {
      docId = documentId?['tomorrow_document_id'] ?? "Not Found ID";
    }
    if (title.toLowerCase() == 'lunch') {
      docId = documentId?['tomorrow_document_id'] ?? "Not Found ID";
    }

    if (preference == "nonveg") {
      fieldCount = '${title.toLowerCase()}_count.non_veg';
    } else {
      fieldCount = '${title.toLowerCase()}_count.veg';
    }

    await _firestore.collection('daily_menus').doc(docId).update({
      fieldCount: FieldValue.increment(-1),
    });
  }

  Future<void> actionForVegButton(ReceivedAction receivedAction) async {
    Map<String, String?>? documentId = receivedAction.payload;
    String? title = documentId?['meal_title'];

    User? user = await fetchUserData();
    String? preference = user?.preference;

    String docId = documentId?['document_id'] ?? "Not Found ID";
    String filedCount = '${title!.toLowerCase()}_count';

    if (title.toLowerCase() == 'breakfast') {
      docId = documentId?['tomorrow_document_id'] ?? "Not Found ID";
    }

    if (preference == "nonveg") {
      filedCount = '${title.toLowerCase()}_count.action_veg';
      await _firestore.collection('daily_menus').doc(docId).update({
        filedCount: FieldValue.increment(1),
      });
    }
  }

  Future<void> actionForNonVegButton(ReceivedAction receivedAction) async {
    Map<String, String?>? documentId = receivedAction.payload;
    String? title = documentId?['meal_title'];

    User? user = await fetchUserData();
    String? preference = user?.preference;

    String docId = documentId?['document_id'] ?? "Not Found ID";
    String filedCount = '${title!.toLowerCase()}_count';

    if (title.toLowerCase() == 'breakfast') {
      docId = documentId?['tomorrow_document_id'] ?? "Not Found ID";
    }

    if (preference == "veg") {
      filedCount = '${title.toLowerCase()}_count.action_non_veg';
      await _firestore.collection('daily_menus').doc(docId).update({
        filedCount: FieldValue.increment(-1),
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getMenusDataFromCloud() async {
    try {
      QuerySnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('daily_menus').get();
      return doc;
    } catch (error) {
      print("Failed to get daily Menu: $error");
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchDailyMenusFromDatabase() async {
    Map<String, dynamic> allMenusOfDay = {};
    User? userData = await fetchUserData();
    final email = userData?.email;
    String unitId = "FzdQ5CB2iEiYBuVd4uBP";
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String tomorrowDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 1)));

    // Fetch data from Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('daily_menus')
        .where('unit_id', isEqualTo: unitId)
        .where('date', isGreaterThanOrEqualTo: currentDate)
        .where('date', isLessThanOrEqualTo: tomorrowDate)
        .orderBy('date', descending: false)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String menuDate = data['date'] ?? '';
        if (menuDate == currentDate) {
          var dinnerArray = data['dinner'] as List?;
          allMenusOfDay['Dinner'] = dinnerArray?.join(', ') ?? 'No data';
          if (data['dinner_response'] != null &&
              data['dinner_response'][email] != null) {
            allMenusOfDay['dinner_response'] = data['dinner_response'][email];
          }
          allMenusOfDay['document_id'] = doc.id;
        }

        if (menuDate == tomorrowDate) {
          var breakfastArray = data['breakfast'] as List?;
          allMenusOfDay['Breakfast'] = breakfastArray?.join(', ') ?? 'No data';
          if (data['breakfast_response'] != null &&
              data['breakfast_response'][email] != null) {
            allMenusOfDay['breakfast_response'] =
                data['breakfast_response'][email];
          }

          var lunchArray = data['lunch'] as List?;
          allMenusOfDay['Lunch'] = lunchArray?.join(', ') ?? 'No data';
          if (data['lunch_response'] != null &&
              data['lunch_response'][email] != null) {
            allMenusOfDay['lunch_response'] = data['lunch_response'][email];
          }

          allMenusOfDay['tomorrow_document_id'] = doc.id;
        }
      }
    } else {
      print("No data found or failed to fetch data.");
    }

    return allMenusOfDay;
  }
}
