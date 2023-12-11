import 'package:blood_donation/screens/admin_login.dart';
import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:blood_donation/screens/reset_pwd.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Define a stateful widget for the login screen
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}
// Define the state for the login screen
class _LoginState extends State<Login> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscureText = true;
  bool _rememberMe = false;
  int? _count;
  int? _cachedLoginCount;
  Future<int>? _loginCountFuture;

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in here
    checkIfUserIsLoggedIn();
    _loginCountFuture = fetchLoginCount();
  }

  // Check if the user is already logged in using shared preferences
  Future<void> checkIfUserIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final String mobileNo = prefs.getString('userMobileNo') ?? '';
      final String password = prefs.getString('userPassword') ?? '';

      setState(() {
        _rememberMe = true;
        _mobileController.text = mobileNo;
        _passwordController.text = password;
      });
    }
  }

  // Navigate to the home page with user details
  void navigateToHomePage(String mobileNo, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(mobileNo: mobileNo, role: role),
      ),
    );
  }

  // Handle the login process
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

    // Send a login request to the server
    final response = await http.post(
      Uri.parse(base_url + 'Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobileNo': mobileNo, 'password': password}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String mobileNo = responseData['mobile_no'].toString();
      final String role = responseData['role'].toString();

      // Navigate to the home page with user details
      navigateToHomePage(mobileNo, role);

      // Save user details in shared preferences if 'Remember Me' is checked
      if (_rememberMe) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userMobileNo', mobileNo);
        prefs.setString('userPassword', password);
        prefs.setBool('rememberUser', true);
      } else {
        // Clear user details from shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('userMobileNo');
        prefs.remove('userPassword');
        prefs.setBool('rememberUser', false);
        _mobileController.text = '';
        _passwordController.text = '';
      }
    } else {
      _showErrorSnackBar('The login credentials are wrong. Please check.');
    }
  }

  // Show a snackbar with an error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Fetch the login count from the server
  Future<int> fetchLoginCount() async {
    // If the count is already cached, return it
    if (_cachedLoginCount != null) {
      return _cachedLoginCount!;
    }

    final String apiUrl = base_url + 'fetchLoginCount';

    try {
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final int count = data['count'];

        // Cache the count for future use
        _cachedLoginCount = count;

        return count;
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
        title: Text('Login', style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    Admin(), //Navigate to Admin Screen
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.manage_accounts,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Admin',
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
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
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
              SizedBox(
                height: 20,
              ),
              // Usage of FutureBuilder with caching
              FutureBuilder<int>(
                future: _loginCountFuture,
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
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else {
                    _count = snapshot.data;
                    return Center(
                      child: Text(
                        'Registered Users - ' + (_count?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
