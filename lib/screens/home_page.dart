// ignore_for_file: deprecated_member_use

import 'package:blood_donation/screens/donor_list.dart';
import 'package:blood_donation/screens/edit_profile.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:blood_donation/screens/users_list.dart';
import 'package:flutter/material.dart';
import 'base_url.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// Define the home page widget
// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  // Declare variables for user mobile number and role
  String mobileNo;
  String role;

  // Constructor to initialize the variables
  HomePage({Key? key, required this.mobileNo, required this.role})
      : super(key: key);

  // Create the state for the home page
  @override
  State<HomePage> createState() => _HomePageState();
}

// Define the state for the home page
class _HomePageState extends State<HomePage> {
  // Declare variables and keys
  final myVersion = '1.2';
  late BuildContext dialogContext;
  late String selectedBloodGroup = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // List of blood groups
  List<String> bloodGroups = [
    '-Select-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Initialize the state
  @override
  void initState() {
    super.initState();
    selectedBloodGroup = '-Select-';
    getUpdates();
    print(widget.role);
  }

  // Function to check for app updates
  Future<void> getUpdates() async {
    try {
      // Prepare data for the update check
      final data = {'name': myVersion};

      // Define the URL for the update check
      final String url = base_url + 'appversionupdate';

      // Send a POST request to check for updates
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      // Decode the response
      final result1 = json.decode(response.body);
      print(result1);

      // Check if an update is available
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

                    // Launch the update URL
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
        print('No update available.');
      }
    } catch (error) {
      // Handle errors during update check
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

  // Build the UI for the home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation App',
         style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // Logout button
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    Login(), // Replace with the actual login screen widget
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 30, 73, 202),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo images
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

            // App title and subtitle
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
            const SizedBox(height: 20),

            // Blood group selection dropdown
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Please Select Blood Group',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 241, 14, 14),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedBloodGroup,
                      items: bloodGroups.map((String bloodGroup) {
                        return DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedBloodGroup = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      isExpanded: false,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value == '-Select-') {
                          // Show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a blood group'),
                            ),
                          );
                          return 'Please select a blood group';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Find a Donor button
            SizedBox(
              height: 45,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate blood group selection
                    if (selectedBloodGroup == '-Select-') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a blood group'),
                        ),
                      );
                    } else if (_formKey.currentState?.validate() ?? false) {
                      // Proceed with the button action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonorListScreen(
                            bloodGroup: selectedBloodGroup,
                            mobileNo: widget.mobileNo,
                            role: widget
                                .role, // Use a default value if widget.role is null
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a blood group'),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 11, 9, 25)),
                  ),
                  child: const Text(
                    'Find A Donor',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Edit Profile button (visible for authenticated users)
            if (widget.role != '0')
              SizedBox(
                height: 45,
                child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                      mobileNo: widget.mobileNo,
                                      role: widget.role)));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 11, 9, 25)),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ))),
              ),

            // Add User button (visible for admin users)
            if (widget.role == '0')
              SizedBox(
                height: 45,
                child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UsersList(
                                      role: widget.role)));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 11, 9, 25)),
                        ),
                        child: Text(
                          'Add User',
                          style: TextStyle(fontSize: 20),
                        ))),
              ),

            const SizedBox(height: 80),

            // App tagline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 100.0), // Adjust the left padding value as desired

                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
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
