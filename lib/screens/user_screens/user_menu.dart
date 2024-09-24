import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/theme/colors.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({Key? key}) : super(key: key);

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final List<Map<String, String>> meals = [
    {"title": "Breakfast", "image": "assets/images/cereals.jpeg"},
    {"title": "Lunch", "image": "assets/images/lunch.jpeg"},
    {"title": "Dinner", "image": "assets/images/dinner.jpeg"},
  ];

  bool _switchValue = true;
  int activeIndex = 0;
  String activeMeal = "Breakfast";

  List<Map<String, dynamic>> weeklyMenu = [];
  bool isLoading = true;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchWeeklyMenu();
  }

  Future<void> fetchWeeklyMenu() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('daily_menus').get();
      final List<Map<String, dynamic>> fetchedMenu = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "date": data['date'],
          "breakfast": List<String>.from(data['breakfast'] ?? []),
          "lunch": List<String>.from(data['lunch'] ?? []),
          "dinner": List<String>.from(data['dinner'] ?? []),
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
      // Optionally, show an error message to the user
    }
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Peek into the menu &",
              style: TextStyle(
                color: AppColors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w100,
              ),
            ),
            SizedBox(
              height: 22, // Set your desired height here
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle the download action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange200.withOpacity(0.7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                ),
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 15.0,
                ),
                label: const Text(
                  "Weekly Menu",
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 5.0),
        const Row(
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
    return SizedBox(
      height: 60.0, // Adjust height as needed
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: weeklyMenu.length,
            onPageChanged: (index) {
              setState(() {
                activeIndex = index;
                activeMeal =
                    "Breakfast"; // Reset meal to Breakfast when changing day
              });
            },
            itemBuilder: (context, index) {
              bool isActive = activeIndex == index;
              return Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      activeIndex = index;
                      activeMeal =
                          "Breakfast"; // Reset meal to Breakfast when changing day
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Add horizontal margin
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color:
                          isActive ? AppColors.orange200 : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weeklyMenu[index]["date"], // Show complete date
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.grey,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
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
                    value: _switchValue,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;
                        // Handle the switch value change here
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
