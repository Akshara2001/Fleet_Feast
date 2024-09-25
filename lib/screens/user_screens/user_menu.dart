import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/screens/user_screens/user_profile.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/theme/colors.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({Key? key}) : super(key: key);

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> meals = [
    {"title": "Breakfast", "image": "assets/images/cereals.jpeg"},
    {"title": "Lunch", "image": "assets/images/lunch.jpeg"},
    {"title": "Dinner", "image": "assets/images/dinner.jpeg"},
  ];
  final List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  int activeIndex = 0;
  String activeMeal = "Breakfast";

  List<Map<String, dynamic>> weeklyMenu = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeeklyMenu();
  }

  Map<String, String> getCurrentWeekRange() {
    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;

    // Calculate start and end of the week
    DateTime startOfWeek =
        now.subtract(Duration(days: dayOfWeek - 1)); // Monday
    DateTime endOfWeek = now.add(Duration(days: 7 - dayOfWeek)); // Sunday

    // Format the dates as 'YYYY-MM-DD'
    String formattedStart = DateFormat('yyyy-MM-dd').format(startOfWeek);
    String formattedEnd = DateFormat('yyyy-MM-dd').format(endOfWeek);

    return {
      'start': formattedStart,
      'end': formattedEnd,
    };
  }

  Future<void> fetchWeeklyMenu() async {
    String unitId = "FzdQ5CB2iEiYBuVd4uBP";
    try {
      // Get start and end dates of the current week
      final week = getCurrentWeekRange();
      String startDate = week['start']!;
      String endDate = week['end']!;

      User? userData = await fetchUserData();
      final email = userData?.email;
      // Query Firestore collection with unit_id, date range, and order by date
      final snapshot = await firestore
          .collection('daily_menus')
          .where('unit_id', isEqualTo: unitId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: false)
          .get();

      final List<Map<String, dynamic>> fetchedMenu = snapshot.docs.map((doc) {
        final data = doc.data();
        bool breakfastResp = true;
        bool lunchResp = true;
        bool dinnerResp = true;

        if (data['breakfast_response'] != null &&
            data['breakfast_response'][email] != null) {
          breakfastResp = data['breakfast_response'][email];
        }
        if (data['lunch_response'] != null &&
            data['lunch_response'][email] != null) {
          lunchResp = data['lunch_response'][email];
        }
        if (data['dinner_response'] != null &&
            data['dinner_response'][email] != null) {
          dinnerResp = data['dinner_response'][email];
        }

        return {
          "date": data['date'],
          "unit_id": data['unit_id'],
          "breakfast": List<String>.from(data['breakfast'] ?? []),
          "lunch": List<String>.from(data['lunch'] ?? []),
          "dinner": List<String>.from(data['dinner'] ?? []),
          "breakfast_response": breakfastResp,
          "lunch_response": lunchResp,
          "dinner_response": dinnerResp,
        };
      }).toList();

      setState(() {
        weeklyMenu = fetchedMenu;
        isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendResponse(
      String date, String unitId, String activeMeal, bool value) async {
    print('response is send to ${date} for ${activeMeal} ');
    User? data = await fetchUserData();
    final email = data?.email;
    final snapshot = await firestore
        .collection('daily_menus')
        .where('unit_id', isEqualTo: unitId)
        .where('date', isEqualTo: date)
        .get();
    final List<String> docIdList = snapshot.docs.map((doc) {
      return doc.id;
    }).toList();

    await firestore.collection('daily_menus').doc(docIdList[0]).set({
      activeMeal: {email: value},
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add horizontal padding
      child: Column(
        children: [
          const SizedBox(height: 15.0),
          _MenuHeader(),
          const SizedBox(height: 38.0),
          isLoading ? _buildLoadingIndicator() : _buildDaySelector(),
          const SizedBox(height: 18.0),
          Container(
            height: 1.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[350],
            ),
          ),
          const SizedBox(height: 15.0),
          isLoading ? Container() : _buildMealSelector(),
          const SizedBox(height: 35.0),
          isLoading ? Container() : _buildMenuItems(),
        ],
      ),
    );
  }

  // Loading Indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // MenuHeader Widget
  Widget _MenuHeader() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Peek into the menu &",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          children: [
            Text(
              "Say if you are in!",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // DaySelector Widget
  Widget _buildDaySelector() {
    // Limit the weekly menu to the first 7 items
    final limitedMenu =
        weeklyMenu.length > 7 ? weeklyMenu.sublist(0, 7) : weeklyMenu;

    return SizedBox(
      height: 70.0, // Adjust height as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(limitedMenu.length, (index) {
          bool isActive = activeIndex == index;

          // Get the day from the weekdays list
          String dayOfWeek = weekdays[index % 7];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayOfWeek,
                style: const TextStyle(color: AppColors.black),
              ),
              const SizedBox(height: 6.0), // Spacing between day and date
              GestureDetector(
                onTap: () {
                  setState(() {
                    activeIndex = index;
                    activeMeal =
                        "Breakfast"; // Reset meal to Breakfast when a day is selected
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.orange200
                        : Colors.transparent, // Highlight active day
                    border: Border.all(
                        color: isActive
                            ? AppColors.orange200
                            : Colors.transparent),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    limitedMenu[index]["date"]
                        .toString()
                        .substring(8, 10), // Show date (DD format)
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[500],
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // MealSelector Widget
  Widget _buildMealSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(meals.length, (index) {
        final meal = meals[index];
        final isActive = meal["title"] == activeMeal;

        return GestureDetector(
          onTap: () => setState(() {
            activeMeal = meal["title"]!;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              color: isActive
                  ? AppColors.orange200.withOpacity(0.88)
                  : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12.0, top: 15.0, bottom: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      meal["image"]!,
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    meal["title"]!,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMenuItems() {
    List<String> foodItems = [];
    switch (activeMeal) {
      case "Breakfast":
        foodItems =
            List<String>.from(weeklyMenu[activeIndex]["breakfast"] ?? []);
        break;
      case "Lunch":
        foodItems = List<String>.from(weeklyMenu[activeIndex]["lunch"] ?? []);
        break;
      case "Dinner":
        foodItems = List<String>.from(weeklyMenu[activeIndex]["dinner"] ?? []);
        break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Dine with us?",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 5.0,
            ),
            SizedBox(
                width: 35,
                height: 18,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch(
                    value: weeklyMenu[activeIndex]
                        ['${activeMeal.toLowerCase()}_response'],
                    onChanged: (bool value) {
                      setState(() {
                        weeklyMenu[activeIndex]
                            ['${activeMeal.toLowerCase()}_response'] = value;
                        print('${activeMeal.toLowerCase()}_response');
                        sendResponse(
                            weeklyMenu[activeIndex]['date'],
                            weeklyMenu[activeIndex]['unit_id'],
                            '${activeMeal.toLowerCase()}_response',
                            value);
                      });
                    },
                    activeTrackColor: Colors.green[400],
                    inactiveTrackColor: Colors.grey[400],
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    trackOutlineColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 10.0),
        Column(
          children: foodItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0), // Space between items
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                color: Colors.white,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(12.0), // Padding inside the container
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
