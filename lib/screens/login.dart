import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscureText = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in here
    checkIfUserIsLoggedIn();
  }

  Future<void> checkIfUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

  if (rememberMe) {
  final String mobile_no = prefs.getString('mobile_no') ?? '';
  final String password = prefs.getString('password') ?? '';

  setState(() {
    _rememberMe = true;
    _mobileController.text = mobile_no; // Set the mobile number from SharedPreferences
    _passwordController.text = password;
  });
}


    if (isLoggedIn) {
      // User is logged in, navigate to SelectStn screen with user data
      navigateToHomePage();
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  Future<void> _login() async {
    final mobileNo = _mobileController.text;
    final password = _passwordController.text;

    if (mobileNo.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please enter both mobile no and password.');
      return;
    }
    if (mobileNo.length != 10) {
    _showErrorSnackBar('Mobile number must be exactly 10 characters.');
    return;
  }

    final response = await http.post(
      Uri.parse(base_url + 'Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobileNo': mobileNo, 'password': password}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String id = responseData['id'].toString();
      final String name = responseData['name'].toString();
      final String mobileNo = responseData['mobile_no'].toString();

      // Call navigateToSelectStn with the required arguments
      navigateToHomePage();

      // Save "Remember Me" data if the checkbox is checked
     if (_rememberMe) {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('mobile_no', mobileNo);
  prefs.setString('password', password);
  prefs.setBool('rememberMe', true);
} else {
  // Clear stored mobile_no and password
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('mobile_no');
  prefs.remove('password');
  prefs.setBool('rememberMe', false);
  // Clear input fields
  _mobileController.text = '';
  _passwordController.text = '';
}

    } else {
      _showErrorSnackBar('An error occurred. Please try again later.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/azadi.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/loginLogo.png',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/g20.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Blood Donation App',
                style: TextStyle(
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'South Central Railway',
                style: TextStyle(
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.02),

              // Username input field
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Please Enter Your Mobile Number',
                  labelText: 'Mobile No',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
  if (value?.isEmpty ?? true) {
    return 'Mobile number is required';
  } else if (value!.length != 10) {
    return 'Mobile number must be 10 characters';
  }
  return null; // Return null if the validation passes
},

              ),
              SizedBox(height: screenSize.height * 0.02),

              // Password input field
              TextFormField(
                controller: _passwordController,
                obscureText:
                    _passwordObscureText, // Toggle visibility with this flag
                decoration: InputDecoration(
                  hintText: 'Please Enter Your Password' ,
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _passwordObscureText =
                            !_passwordObscureText; // Toggle the password visibility
                      });
                    },
                    child: Icon(
                      _passwordObscureText
                          ? Icons.visibility_off
                          : Icons
                              .visibility, // Toggle the icon based on visibility
                      color: Colors.grey, // Adjust the color as needed
                    ),
                  ),
                ),
              ),

              // Remember Me checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Remember Me'),
                controlAffinity: ListTileControlAffinity.leading,
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),

// Buttons in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(fontSize: screenSize.width * 0.05),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: screenSize.width * 0.05),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
