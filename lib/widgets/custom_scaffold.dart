import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    this.child,
  });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image with Overlay
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/welcomeImage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay Container
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.1), // Adjust opacity as needed
          ),
          // Content (inside SafeArea)
          SafeArea(child: child!),
        ],
      ),
    );
  }
}
