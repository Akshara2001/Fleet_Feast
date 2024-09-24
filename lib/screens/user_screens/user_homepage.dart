import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_screens/user_feedback.dart';
import 'package:flutter_application_1/screens/user_screens/user_menu.dart';
import 'package:flutter_application_1/screens/user_screens/user_profile.dart';
import 'package:flutter_application_1/theme/colors.dart';
import 'package:flutter_application_1/widgets/icon_only_navigation.dart';

class UserHomepage extends StatefulWidget {
  const UserHomepage({Key? key}) : super(key: key);

  @override
  State<UserHomepage> createState() => _UserHomepageState();
}

class _UserHomepageState extends State<UserHomepage> {
  int currentPageIndex = 1;
  String wardroomName = "Valsura";

  void _onItemTapped(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey[200],
        surfaceTintColor: Colors.white,
        elevation: 4.0,
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.storefront,
              color: AppColors.grey,
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              "${wardroomName.toUpperCase()} WARDROOM",
              style: const TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: AppColors.orange200,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.grey,
        height: 60.0,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          IconOnlyNavigation(
            icon: Icon(
              Icons.rate_review_outlined,
              color: Colors.grey[400],
              size: 30.0,
            ),
            selectedIcon: const Icon(
              Icons.rate_review_outlined,
              color: AppColors.orange200,
              size: 30.0,
            ),
            isSelected: currentPageIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          IconOnlyNavigation(
            icon: Icon(
              Icons.restaurant_menu,
              color: Colors.grey[400],
              size: 30.0,
            ),
            selectedIcon: const Icon(
              Icons.restaurant_menu,
              color: AppColors.orange200,
              size: 30.0,
            ),
            isSelected: currentPageIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          IconOnlyNavigation(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.grey[400],
              size: 30.0,
            ),
            selectedIcon: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.orange200,
              size: 30.0,
            ),
            isSelected: currentPageIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: <Widget>[
          const UserFeedback(),
          const UserMenu(),
          const UserProfile(),
        ],
      ),
    );
  }
}
