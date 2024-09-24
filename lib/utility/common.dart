import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/screens/user_screens/user_profile.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';

// Initialize LocalStorage
final LocalStorage storage = LocalStorage('my_data');
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Save user data to local storage
Future<void> saveUserDataToLocal(Map<String, dynamic> user) async {
  await clearUserDataOfLocal();
  await storage.setItem('user', user);
}

// Retrieve user data from local storage
Future<Map<String, dynamic>?> getUserDataFromLocal() async {
  await storage.ready;
  final user = storage.getItem('user');
  return user != null ? Map<String, dynamic>.from(user) : null;
}

// Clear user data from local storage
Future<void> clearUserDataOfLocal() async {
  await storage.deleteItem('user');
}

String getToday() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('ddMMyyyy').format(now);
  return formattedDate;
}

List<Map<String, String>> getWeekDates(DateTime date) {
  // Find the start of the week (Monday)
  int differenceToMonday = date.weekday - DateTime.monday;
  DateTime monday = date.subtract(Duration(days: differenceToMonday));

  // Generate the list of dates with their day names
  List<Map<String, String>> weekDates = [];
  for (int i = 0; i < 7; i++) {
    DateTime weekDate = monday.add(Duration(days: i));
    String dayName = DateFormat('EEEE').format(weekDate).substring(0, 3);
    String formattedDate = DateFormat('ddMMyyyy').format(weekDate);
    weekDates.add({"day": dayName, "date": formattedDate});
  }

  return weekDates;
}

List<Map<String, String>> getCurrentWeekday() {
  String inputDateStr = getToday();
  String dayStr = inputDateStr.substring(0, 2);
  String monthStr = inputDateStr.substring(2, 4);
  String yearStr = inputDateStr.substring(4, 8);

  int day = int.parse(dayStr);
  int month = int.parse(monthStr);
  int year = int.parse(yearStr);

  DateTime inputDate = DateTime(year, month, day);
  return getWeekDates(inputDate);
}

Future<List<bool>> getResponsesFromCloud(String date, String email) async {
  List<bool> output = [];
  try {
    DocumentSnapshot doc =
        await _firestore.collection('response').doc(date).get();
    if (doc.exists) {
      dynamic data = doc.data() as Map<String, dynamic>;
      if (data['breakfast'] != null && data['breakfast'][email] != null) {
        print(data['breakfast'][email]);
        bool value = data['breakfast'][email] ?? true;
        output.add(value);
      } else {
        output.add(true);
      }
      if (data['lunch'] != null && data['lunch'][email] != null) {
        print(data['lunch'][email]);
        bool value = data['lunch'][email] ?? true;
        output.add(value);
      } else {
        output.add(true);
      }
      if (data['dinner'] != null && data['dinner'][email] != null) {
        print(data['dinner'][email]);
        bool value = data['dinner'][email] ?? true;
        output.add(value);
      } else {
        output.add(true);
      }
      return output;
    }
  } catch (error) {
    print("Failed to get response: $error");
  }
  return [true, true, true];
}

Future<Map<String, dynamic>?> getMenuDataFromCloud(String date) async {
  try {
    DocumentSnapshot doc =
        await _firestore.collection('daily_menu').doc(date).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
  } catch (error) {
    print("Failed to get user: $error");
  }
  return null;
}

Future<List<dynamic>> getMenu(String date, String email) async {
  Map<String, dynamic>? data = await getMenuDataFromCloud(date);
  List<bool> responses = await getResponsesFromCloud(date, email);
  if (data != null &&
      data['breakfast'] != null &&
      data['lunch'] != null &&
      data['dinner'] != null) {
    return [
      {
        "meal": "Breakfast",
        "food": data['breakfast'],
        'response': responses[0]
      },
      {"meal": "Lunch", "food": data['lunch'], 'response': responses[1]},
      {"meal": "Dinner", "food": data['dinner'], 'response': responses[2]},
    ];
  }

  return [
    {"meal": "Breakfast", "food": [], 'response': responses[0]},
    {"meal": "Lunch", "food": [], 'response': responses[1]},
    {"meal": "Dinner", "food": [], 'response': responses[2]},
  ];
}

Future<List<Map<String, dynamic>>> getData() async {
  List<Map<String, String>> days = getCurrentWeekday();
  List<Map<String, dynamic>> output = [];
  User? data = await fetchUserData();
  final email = data?.email;
  for (int i = 0; i < days.length; i++) {
    Map<String, dynamic> curDay = days[i];
    output.add({
      "date": curDay['date'],
      "day": curDay['day'],
      "menu": await getMenu(curDay['date'], email!),
    });
  }
  return output;
}

Future<void> sendResponse(String date, String type, bool value) async {
  User? data = await fetchUserData();
  final email = data?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int inVal = 0;
  if (value) {
    inVal = 1;
  } else {
    inVal = -1;
  }
  if (type == 'Lunch') {
    await _firestore.collection('daily_menu').doc(date).set({
      'lunch_count': {
        data?.preference: FieldValue.increment(inVal),
      }
    }, SetOptions(merge: true));
    await _firestore.collection('response').doc(date).set({
      'lunch': {email: value},
    }, SetOptions(merge: true));
  } else if (type == 'Breakfast') {
    await _firestore.collection('daily_menu').doc(date).set({
      'breakfast_count': {
        data?.preference: FieldValue.increment(inVal),
      }
    }, SetOptions(merge: true));
    await _firestore.collection('response').doc(date).set({
      'breakfast': {email: value},
    }, SetOptions(merge: true));
  } else {
    await _firestore.collection('daily_menu').doc(date).set({
      'dinner_count': {
        data?.preference: FieldValue.increment(inVal),
      }
    }, SetOptions(merge: true));
    await _firestore.collection('response').doc(date).set({
      'dinner': {email: value},
    }, SetOptions(merge: true));
  }
}

Future<void> get dataForUnitName async {
  print("Unit Names Data Collection Started ................");
  QuerySnapshot<Map<String, dynamic>>? unitNames = await getDataForUnitNames();
  allUnitNames.clear();
  if (unitNames != null) {
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in unitNames.docs) {
      Map<String, dynamic> data = doc.data();
      String unitName = data['unit_name'] ?? 'Pune';

      allUnitNames.add(DropdownMenuEntry(
        value: unitName,
        label: unitName,
      ));
    }
  }
}

Future<QuerySnapshot<Map<String, dynamic>>?> getDataForUnitNames() async {
  try {
    QuerySnapshot<Map<String, dynamic>> unitNames =
        await _firestore.collection('units').get();
    return unitNames;
  } catch (error) {
    print("Failed to get Unit Names: $error");
    return null;
  }
}
