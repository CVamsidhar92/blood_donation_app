 import 'package:flutter/material.dart';
import 'donor_register.dart';
import 'find_donor.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 54, 154),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/azadi.jpeg',
                    height: 50,
                    width: 50,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/loginLogo.jpeg',
                    height: 70,
                    width: 70,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/g20.jpeg',
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
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 4, 4, 28)),
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
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 11, 9, 25)),
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
                  padding: const EdgeInsets.only(left: 100.0), // Adjust the left padding value as desired

                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'B',
                          style: TextStyle(color: Color.fromARGB(255, 153, 208, 14)),
                        ),
                        TextSpan(
                          text: ' - Beautiful',
                          style: TextStyle(color: Color.fromARGB(255, 225, 227, 220)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'L',
                          style: TextStyle(color: Color.fromARGB(255, 122, 233, 48)),
                        ),
                        TextSpan(
                          text: ' - Life',
                          style: TextStyle(color: Color.fromARGB(255, 238, 233, 228)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'O',
                          style: TextStyle(color: Color.fromARGB(255, 109, 235, 25)),
                        ),
                        TextSpan(
                          text: ' - Only',
                          style: TextStyle(color: Color.fromARGB(255, 226, 222, 219)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'O',
                          style: TextStyle(color: Color.fromARGB(255, 111, 233, 30)),
                        ),
                        TextSpan(
                          text: ' - On',
                          style: TextStyle(color: Color.fromARGB(255, 236, 233, 230)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 100.0), // Adjust the left padding value as desired
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'D',
                          style: TextStyle(color: Color.fromARGB(255, 98, 213, 15)),
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
