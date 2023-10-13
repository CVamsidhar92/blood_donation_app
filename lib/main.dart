import 'package:flutter/material.dart';
import 'package:blood_donation/home_page.dart' as Home;

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
      home: const Home.HomePage(), // Specify the HomePage using the assigned prefix
    );
  }
}
