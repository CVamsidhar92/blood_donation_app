import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';


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

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  String otp = '';
 Future<void> verifyOtp(
      String name, String password, String mobileNumber, String otp) async {
    final String apiUrl = base_url + 'verifyOtp';

    final Map<String, dynamic> data = {
      'mobileNo': mobileNumber,
      'otp': otp,
      'name': name,
      'password': password,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic>? dataList =
          responseData['data']; // Add '?' for null safety

      if (dataList != null && dataList.isNotEmpty) {
        // Check for null before accessing properties
        final Map<String, dynamic> userData = dataList[0];
        final String receivedOtp = userData['otp'];

        if (receivedOtp == otp) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP is valid'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(mobileNo: mobileNumber),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
          ),
        );
      }
    } else {
      // Print the error response body
      print('Error response body: ${response.body}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying OTP. Please try again.'),
        ),
      );
    }
  }

  void _onVerifyButtonPressed() {
    if (otp.isEmpty) {
      // Show a red SnackBar for empty OTP input field
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter OTP',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          backgroundColor: Colors.red, // Set background color to red
        ),
      );
      return; // Exit the method if OTP is empty
    }

    if (_formKey.currentState!.validate()) {
      verifyOtp(widget.name, widget.password, widget.mobile, otp);
      print('OTP verification initiated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Screen'),
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
                    Image.asset(
                      'assets/images/otpicon.png', // Replace with the path to your image
                      height: 100, // Adjust the height as needed
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Please enter the OTP sent to your mobile number',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
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
                            alignment: Alignment.center, // Center the text
                            child: Text(
                              'OTP', // Replace with your desired text
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
}
