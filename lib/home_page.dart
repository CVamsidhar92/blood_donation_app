// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'donor_register.dart';
import 'find_donor.dart';
import 'base_url.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myVersion = '1.2';
  late BuildContext dialogContext;

  @override
  void initState() {
    super.initState();
    getUpdates();
  }

  Future<void> getUpdates() async {
    try {
      final data = {'name': myVersion};

      final String url = base_url + 'appversionupdate';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      final result1 = json.decode(response.body);
      print(result1);

      if (myVersion != result1[0]['appversion']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            dialogContext = context;
            return AlertDialog(
              title: const Text('Please Update'),
              content: Text(
                'You must update the app to the latest version to continue using. Latest version is ${result1[0]['appversion']} and your version is $myVersion',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    String url = (result1[0]['update_url']);
                    try {
                      await launch(url);
                      SystemNavigator.pop(); // Add this line to exit the app
                    } catch (e) {
                      print("URL can't be launched.");
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      } else {
        // Uncomment the below line if you have implemented AsyncStorage in your app
        // await AsyncStorage.setItem('forceUpdateAlertShown', 'false');
        print('No update available.');
      }
    } catch (error) {
      print("Error: $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation App'),
      ),
      backgroundColor: Color.fromARGB(255, 30, 73, 202),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/azadia.jpeg',
                    height: 50,
                    width: 50,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/loginLogo.png',
                    height: 70,
                    width: 70,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/g20a.jpeg',
                    height: 50,
                    width: 50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 15),
            const Text(
              'BLOOD DONOR FINDER',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 229, 194, 55),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'South Central Railway',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 180, 241, 14),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 0.5,
              height: 45,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NextPage()),
                    );
                    // Handle button press
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 4, 4, 28)),
                  ),
                  child: const Text(
                    'Register As Donor',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindDonor()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 11, 9, 25)),
                  ),
                  child: const Text(
                    'Find A Donor',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired

                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'B',
                          style: TextStyle(
                              color: Color.fromARGB(255, 153, 208, 14)),
                        ),
                        TextSpan(
                          text: ' - Beautiful',
                          style: TextStyle(
                              color: Color.fromARGB(255, 225, 227, 220)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'L',
                          style: TextStyle(
                              color: Color.fromARGB(255, 122, 233, 48)),
                        ),
                        TextSpan(
                          text: ' - Life',
                          style: TextStyle(
                              color: Color.fromARGB(255, 238, 233, 228)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'O',
                          style: TextStyle(
                              color: Color.fromARGB(255, 109, 235, 25)),
                        ),
                        TextSpan(
                          text: ' - Only',
                          style: TextStyle(
                              color: Color.fromARGB(255, 226, 222, 219)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'O',
                          style: TextStyle(
                              color: Color.fromARGB(255, 111, 233, 30)),
                        ),
                        TextSpan(
                          text: ' - On',
                          style: TextStyle(
                              color: Color.fromARGB(255, 236, 233, 230)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'D',
                          style: TextStyle(
                              color: Color.fromARGB(255, 98, 213, 15)),
                        ),
                        TextSpan(
                          text: ' - Donating',
                          style: TextStyle(
                            color: Color.fromARGB(255, 226, 237, 239),
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
