import 'dart:convert';
import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/new_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ResetPwd extends StatefulWidget {
  const ResetPwd({Key? key}) : super(key: key);

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool isRegistered = false;
  bool isResetClicked = false;

  // Sends the mobile number to the server to request OTP
  Future<void> sendMobileNumber(String mobileNumber) async {
    bool isUserExists = await checkUserExistence();

    if (!isUserExists) {
      // Display an error message if the mobile number is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mobile number not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare data and send it to the server
    Map<String, dynamic> formData = {
      'mobileNumber': mobileNumber,
    };
    String jsonData = jsonEncode(formData);
    http.post(
      Uri.parse(base_url + 'resetPswd'),
      body: jsonData,
      headers: {'Content-Type': 'application/json'},
    ).then((response) {
      if (response.statusCode == 200) {
        // OTP sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Sent Successfully. Please Enter OTP'),
            backgroundColor: Colors.green,
          ),
        );

        // Update UI to show OTP input field
        setState(() {
          isRegistered = true;
        });
      } else {
        // Error sending OTP
        print('Error sending OTP');
      }
    });
  }

  // Checks if the user exists in the database
  Future<bool> checkUserExistence() async {
    Uri checkUrl = Uri.parse(base_url + 'resetCheckUser');
    http.Response checkResponse = await http.post(checkUrl, body: {
      'mobileNumber': _mobileController.text,
    });

    if (checkResponse.statusCode == 200 && checkResponse.body.isNotEmpty) {
      Map<String, dynamic> responseData = json.decode(checkResponse.body);
      String status = responseData['status'];
      return status == '200';
    } else {
      return false;
    }
  }

  // Verifies the entered OTP with the server
  Future<void> verifyOtp(String mobileNumber, String otp) async {
    final String apiUrl = base_url + 'resetVerifyOTP';

    final Map<String, dynamic> data = {
      'mobileNo': mobileNumber,
      'otp': otp,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      int status = responseData['status'];

      if (status == 200) {
        // Valid OTP, navigate to the new password screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP is valid'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPassword(mobileNo: mobileNumber),
          ),
        );
      } else {
        // Invalid OTP, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
          ),
        );
      }
    } else {
      // Error handling for OTP verification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying OTP. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password',
         style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 22, right: 22),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display the image/logo for resetting password
              Image.asset(
                'assets/images/reset-pwd.png',
                height: 150,
              ),
              SizedBox(height: 20,),
              Center(
                child: Text(
                  'Please Enter Your Mobile Number',
                  style: TextStyle(
                    color: Color.fromARGB(255, 33, 184, 243),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Input field for entering the mobile number
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                readOnly: isRegistered,
                decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Mobile number is required';
                  } else if (value!.length != 10) {
                    return 'Mobile number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              // If registered, show OTP input field
              if (isRegistered)
                Column(
                  children: [
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        labelText: 'OTP',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Add OTP validation logic if needed
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              // If not registered, show "Send OTP" button
              if (!isRegistered)
                Center(
                  child: SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate and send mobile number for OTP
                        if (_mobileController.text.length == 10 &&
                            !isResetClicked) {
                          sendMobileNumber(_mobileController.text);
                        } else if (_mobileController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please Enter Your Mobile Number'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (_mobileController.text.length == 10 &&
                            isResetClicked) {
                          // Add verification logic here if needed
                          // You can check the OTP and perform necessary actions
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Mobile number must be exactly 10 digits.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Send OTP',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              // If registered, show "Verify OTP" button
              if (isRegistered)
                Center(
                  child: SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate and verify OTP
                        if (_otpController.text.isNotEmpty) {
                          verifyOtp(
                            _mobileController.text,
                            _otpController.text,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter the OTP.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
