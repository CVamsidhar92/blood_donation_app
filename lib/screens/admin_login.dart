import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscureText = true;
  bool _rememberMe = false;
  String name = '';

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
      final String username = prefs.getString('adminName') ?? '';
      final String password = prefs.getString('adminPassword') ?? '';

      setState(() {
        _rememberMe = true;
        _usernameController.text = username;
        _passwordController.text = password;
      });
    }
  }

  void navigateToHomePage(String mobileNo, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(mobileNo: mobileNo, role: role),
      ),
    );
  }

  Future<void> _adminLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please enter both username and password.');
      return;
    }

    final response = await http.post(
      Uri.parse(base_url + 'adminLogin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == 200) {
        final String name = responseData['data'][0]['name'].toString();
        final String mobileNo = responseData['data'][0]['mobile_no'].toString();
        final String role = responseData['data'][0]['role'].toString();
        navigateToHomePage(mobileNo, role);

        if (_rememberMe) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('adminName', name);
          prefs.setString('adminPassword', password);
          prefs.setBool('rememberAdmin', true);
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('adminName');
          prefs.remove('adminPassword');
          prefs.setBool('rememberAdmin', false);
          _usernameController.text = '';
          _passwordController.text = '';
        }
      } else {
        _showErrorSnackBar(responseData['message']);
      }
    } else {
      _showErrorSnackBar(
          'Error communicating with the server. Please try again.');
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
        title: Text('Admin Login'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    Login(), // Replace with the actual login screen widget
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Login',
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
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Please Enter Your Username',
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Username is required';
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
              ElevatedButton(
                onPressed: _adminLogin,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: screenSize.width * 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
