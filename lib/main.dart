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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => Splash(),
        '/Login': (context) => Login(),
         '/Register': (context) => Register(),
      },
    );
  }
}
