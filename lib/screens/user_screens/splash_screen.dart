import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5)); // Adjust the duration as needed
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              WelcomeScreen()), // Adjust to your desired screen
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.orange, // Choose a background color that fits your theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Icon(
                Icons.fastfood,
                size: 100.0,
                color: Colors.white, // Color of the icon
              ),
            ),
            SizedBox(height: 20.0),

            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Fleet Feast',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Color of the text
                ),
              ),
            ),
            // Text(
            //   'Fleet Feast',
            //   style: TextStyle(
            //     fontSize: 24.0,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white, // Color of the text
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
