import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigateToLogin();
  }

  void navigateToLogin() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context,
          '/Login'); // Updated route name to match the defined route
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/splash.jpeg',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.0),
              Text(
                'South Central Railway',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
