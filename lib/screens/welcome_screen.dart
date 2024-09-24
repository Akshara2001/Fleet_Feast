import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_screens/user_homepage.dart';
import 'package:flutter_application_1/screens/user_screens/user_login.dart';
import 'package:flutter_application_1/utility/common.dart';
import 'package:flutter_application_1/widgets/custom_scaffold.dart';

Future<void> doLogin(context) async {
  dynamic data = await getUserDataFromLocal();
  if (data != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserHomepage()),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    doLogin(context);
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 160.0),
            const Text(
              'Be Part\nof the Change',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 22),
            const Text(
              'Check-in & Help Minimize Food Waste',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 170),
            // Remove the Wardroom Login button section
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserLogin()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                      color: Colors.white,
                      width: 1), // Customize the outline color
                ),
                child: const Text('Officer Login',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
