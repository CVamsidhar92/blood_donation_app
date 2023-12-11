// Import necessary packages and files
import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// OtpScreen widget for OTP verification
class OtpScreen extends StatefulWidget {
  final String name;
  final String password;
  final String mobile;
  const OtpScreen(
      {Key? key,
      required this.name,
      required this.password,
      required this.mobile})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

// _OtpScreenState manages the state for the OtpScreen widget
class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  String otp = ''; // Holds the entered OTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Screen',
         style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading for entering donor details
                const Text(
                  'Enter Donor Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 249, 28, 46),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    // Image for OTP screen
                    Image.asset(
                      'assets/images/otpicon.png',
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Please enter the OTP sent to your mobile number',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    // OTP input field
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            otp = value;
                          });
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          prefix: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'OTP',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Verify OTP button
                    ElevatedButton(
                      onPressed: _onVerifyButtonPressed,
                      child: Text('Verify OTP'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Called when the "Verify OTP" button is pressed
  void _onVerifyButtonPressed() async {
    if (otp.isEmpty) {
      // Show a red SnackBar for empty OTP input field
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter OTP',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Verify OTP with the server
      bool otpVerified =
          await verifyOtp(widget.name, widget.password, widget.mobile, otp);

      if (otpVerified) {
        // Set a flag in shared preferences to indicate OTP verification
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('otpVerified', true);

        // Navigate to the Login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      } else {
        // Show an error message if OTP is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
          ),
        );
      }
    }
  }

  // Sends OTP to the server for verification
  Future<bool> verifyOtp(
      String name, String password, String mobileNumber, String otp) async {
    final String apiUrl = base_url + 'verifyOtp';

    final Map<String, dynamic> data = {
      'mobileNo': mobileNumber,
      'otp': otp,
      'name': name,
      'password': password,
    };

    try {
      // Make a POST request to the server
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic>? dataList = responseData['data'];

        if (dataList != null && dataList.isNotEmpty) {
          final Map<String, dynamic> userData = dataList[0];
          final String receivedOtp = userData['otp'];

          // Return true if received OTP matches the entered OTP
          return receivedOtp == otp;
        } else {
          // Return false if data list is empty
          return false;
        }
      } else {
        // Log and return false in case of an error
        print('Error response body: ${response.body}');
        return false;
      }
    } catch (e) {
      // Log and return false in case of an exception
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
