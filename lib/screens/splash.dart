import 'package:flutter/material.dart';
import 'dart:async';

// Splash screen widget displayed when the app is launched
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

// State class for the Splash widget
class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigateToLogin(); // Initiates the navigation to the login screen after a delay
  }

  // Navigates to the login screen after a delay
  void navigateToLogin() {
    Timer(Duration(seconds: 3), () {
      // Use a Timer to delay the navigation by 3 seconds
      Navigator.pushReplacementNamed(
        context,
        '/Login',
      ); // Updated route name to match the defined route
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold is a basic material design visual layout structure
    return Scaffold(
      body: Container(
        // Container is a box model to hold and style other widgets
        color: Colors.white, // Set background color to white
        child: Center(
          // Center widget aligns its child to the center of the screen
          child: Column(
            // Column is a vertical arrangement of widgets
            mainAxisAlignment: MainAxisAlignment.center,
            // Align children at the center of the column
            children: [
              // Display the app logo
              Image.asset(
                'assets/images/splash.jpeg',
                width: 200,
                height: 200,
                fit: BoxFit.contain, // Ensure the image fits within the box
              ),
              SizedBox(height: 16.0), // Empty space with a height of 16 pixels
              // Display the app name
              Text(
                'South Central Railway',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Display the app subtitle
              Text(
                'Blood Donation App',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
