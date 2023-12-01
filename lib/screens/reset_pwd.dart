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

  Future<void> sendMobileNumber(String mobileNumber) async {
    final Uri apiUrl = Uri.parse(base_url + 'resetPswd');

    bool isUserExists = await checkUserExistence();

    if (!isUserExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mobile number not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> formData = {
      'mobileNumber': mobileNumber,
    };
    String jsonData = jsonEncode(formData);
    http.post(apiUrl,
        body: jsonData,
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        // Data successfully sent to the API
        print('Data sent successfully');
        print('Response: ${response.body}');

         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Sent Successfully.Please Enter OTP'),
          backgroundColor: Colors.green,
        ),
      );

        // Update UI to show OTP input field
        setState(() {
          isRegistered = true;
        });
      } else {
        // Error sending data to the API
        print('Error sending data');
      }
    });
  }

Future<bool> checkUserExistence() async {
  Uri checkUrl = Uri.parse(base_url + 'resetCheckUser');
  http.Response checkResponse = await http.post(checkUrl, body: {
    'mobileNumber': _mobileController.text,
  });

  if (checkResponse.statusCode == 200 && checkResponse.body.isNotEmpty) {
    Map<String, dynamic> responseData = json.decode(checkResponse.body);
    String status = responseData['status'];
    if (status == '200') {
      return true;
    } else {
      // Handle the case where the user is not found in the login table
    
      return false;
    }
  } else {
    return false;
  }
}


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
    print('Response data: $responseData'); // Print the response data for debugging

    int status = responseData['status'];

    if (status == 200) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
        ),
      );
    }
  } else {
    print('Error response body: ${response.body}');
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
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please Enter Your Mobile Number',
              style: TextStyle(
                color: Color.fromARGB(255, 33, 184, 243),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.number,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              readOnly:
                  isRegistered, // Make read-only when OTP text field is visible
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
             if (!isRegistered)
            Center(
              child: SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
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
                      // Add verification logic here
                      // You can check the OTP and perform the necessary actions
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Mobile number must be exactly 10 digits.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text( 'Send OTP',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                
              ),
            ),
           if (isRegistered)
  Center(
    child: SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: () {
          if (_otpController.text.isNotEmpty) {
            verifyOtp(
              _mobileController.text,
              _otpController.text
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
    );
  }
}
