import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/donor_register.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:blood_donation/screens/otp_screen.dart';
import 'package:blood_donation/screens/reset_pwd.dart';
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
  String name = '';
  int? _count;
  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in here
    checkIfUserIsLoggedIn();
     fetchLoginCount();
  }

  Future<void> checkIfUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final String mobileNo = prefs.getString('mobile_no') ?? '';
      final String password = prefs.getString('password') ?? '';

      setState(() {
        _rememberMe = true;
        _mobileController.text = mobileNo;
        _passwordController.text = password;
      });
    }
  }

  void navigateToHomePage(String mobileNo) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(mobileNo: mobileNo),
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
      final String name = responseData['name'].toString();
      final String mobileNo = responseData['mobile_no'].toString();

      navigateToHomePage(mobileNo);

      if (_rememberMe) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('mobile_no', mobileNo);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', true);
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('mobile_no');
        prefs.remove('password');
        prefs.setBool('rememberMe', false);
        _mobileController.text = '';
        _passwordController.text = '';
      }
    } else {
      _showErrorSnackBar('The login credentials are wrong.Please check.');
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

  Future<void> fetchLoginCount() async {
    try {
      int count = await fetchLoginCountFromApi();
      setState(() {
        _count = count;
      });
    } catch (e) {
      print('Error fetching login count: $e');
    }
  }

Future<int> fetchLoginCountFromApi() async {
  final String apiUrl = base_url + 'fetchLoginCount';

  try {
    final response = await http.post(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['count'];
    } else {
      print('Error response status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load login count');
    }
  } catch (e) {
    print('Error fetching login count: $e');
    throw Exception('Failed to load login count');
  }
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
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: _passwordObscureText,
                decoration: InputDecoration(
                  hintText: 'Please Enter Your Password',
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _passwordObscureText = !_passwordObscureText;
                      });
                    },
                    child: Icon(
                      _passwordObscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: screenSize.width * 0.05),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/Register');
                    },
                    child: Text(
                      'Sign-up',
                      style: TextStyle(fontSize: screenSize.width * 0.05),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final mobileNo = _mobileController.text;
                    final password = _passwordController.text;

                    // Validate if mobileNo and password are not empty
                    if (mobileNo.isEmpty || password.isEmpty) {
                      _showErrorSnackBar(
                          'Please enter both mobile no and password.');
                      return;
                    }

                    // Navigate to the OTP screen with the entered values
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPwd(),
                      ),
                    );
                  },
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                
              ),
              SizedBox(height: 20,),
            FutureBuilder<int>(
  future: fetchLoginCountFromApi(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error loading login count',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red, // You can customize the color
          ),
        ),
      );
    } else {
      _count = snapshot.data;
      return Center(
        child: Text(
          'Registered Users - ' + (_count?.toString() ?? ''),
          style: TextStyle(
            fontSize: 18, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // You can customize the font weight
            color: Colors.red
          ),
        ),
      );
    }
  },
),

            ],
          ),
        ),
      ),
    );
  }
}
