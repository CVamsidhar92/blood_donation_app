import 'package:blood_donation/screens/donor_register.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:blood_donation/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the initial route to the Splash screen
      initialRoute: '/splash',
      // Define named routes for navigation
      routes: {
        '/splash': (context) => Splash(), // Route for the Splash screen
        '/Login': (context) => Login(),   // Route for the Login screen
        '/Register': (context) => Register(), // Route for the Register screen
      },
    );
  }
}
