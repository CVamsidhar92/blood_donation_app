import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  String selectedBloodGroup = '';
  String designation = '';
  String officeArea = '';
  String officeStreet = '';
  String officeCity = '';
  String officePincode = '';
  String officeDistrict = '';
  String officeState = '';
  String officeCountry = 'India';
  String area1 = '';
  String street1 = '';
  String city1 = '';
  String pincode1 = '';
  String district1 = '';
  String state1 = '';
  String mobileNumber = '';
  String country1 = 'India';
  var officeLatitude = 0.0;
  var officeLongitude = 0.0;
  var residentialLatitude = 0.0;
  var residentialLongitude = 0.0;
  bool isRegistered = false;
  bool areInputFieldsEnabled = true; // Add this variable
  String password = '';
  String confirmPassword = '';

  List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'A1+',
    'A1-',
    'A2+',
    'A2-',
    'A1B+',
    'A1B-',
    'A2B+',
    'A2B-'
  ];
  TextEditingController officeLatitudeController = TextEditingController();
  TextEditingController officeLongitudeController = TextEditingController();
  TextEditingController residentialLatitudeController = TextEditingController();
  TextEditingController residentialLongitudeController =
      TextEditingController();
  String otp = '';

  // Function to fetch latitude and longitude from address
  Future<Map<String, double>> getLatLngFromAddress(
      String street, String area, String city, String state) async {
    final apiKey = 'API_KEY'; // Replace with your API key
    final fullAddress = '$street, $area, $city, $state';
    final encodedAddress = Uri.encodeFull(fullAddress);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'][0];
      final location = results['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];

      print('Fetched coordinates for $fullAddress: Lat: $lat, Lng: $lng');
      return {'latitude': lat, 'longitude': lng};
    } else {
      print('Failed to fetch coordinates for $fullAddress');
      throw Exception('Failed to fetch coordinates');
    }
  }

  // Call this function to get latitude and longitude for both addresses
  Future<void> getAddressCoordinates() async {
    try {
      var officeLatLng = await getLatLngFromAddress(
        officeStreet,
        officeArea,
        officeCity,
        officeState,
      );

      var residentialLatLng = await getLatLngFromAddress(
        street1,
        area1,
        city1,
        state1,
      );

      print('Office Latitude: ${officeLatLng['latitude']}');
      print('Office Longitude: ${officeLatLng['longitude']}');
      print('Residential Latitude: ${residentialLatLng['latitude']}');
      print('Residential Longitude: ${residentialLatLng['longitude']}');

      // Set the text controllers after coordinates have been fetched
      setState(() {
        officeLatitude = officeLatLng['latitude'] as double;
        officeLongitude = officeLatLng['longitude'] as double;
        residentialLatitude = residentialLatLng['latitude'] as double;
        residentialLongitude = residentialLatLng['longitude'] as double;
      });
      setState(() {
        // After setting the values in the state, you can update the controllers
        officeLatitudeController.text = officeLatitude.toString();
        officeLongitudeController.text = officeLongitude.toString();

        residentialLatitudeController.text = residentialLatitude.toString();

        residentialLongitudeController.text = residentialLongitude.toString();
      });
    } catch (e) {
      // Handle error
      print('Error fetching coordinates: $e');
    }
  }

  // Call API Start
  void registerDonor() {
    // Call the function to fetch latitude and longitude
    getAddressCoordinates();

    if (!_formKey.currentState!.validate()) {
      // Form validation failed, do not proceed with the API call
      return;
    }

    // Rest of your code for API call goes here...
    // Create a map to hold the form data
    Map<String, dynamic> formData = {
      'name': name,
      'bloodGroup': selectedBloodGroup,
      'designation': designation,
      'officeArea': officeArea,
      'officeStreet': officeStreet,
      'officeCity': officeCity,
      'officePincode': officePincode,
      'officeDistrict': officeDistrict,
      'officeState': officeState,
      'officeCountry': officeCountry,
      'area1': area1,
      'street1': street1,
      'city1': city1,
      'pincode1': pincode1,
      'district1': district1,
      'state1': state1,
      'country1': country1,
      'mobileNumber': mobileNumber,
      'officeLatitude': officeLatitude,
      'officeLongitude': officeLongitude,
      'residentialLatitude': residentialLatitude,
      'residentialLongitude': residentialLongitude,
      'password': password
    };

    // Convert the form data to JSON
    String jsonData = jsonEncode(formData);

    // Make a POST request to the API endpoint
    Uri url = Uri.parse(base_url + 'register');
    http.post(url,
        body: jsonData,
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        // Data successfully sent to the API
        print('Data sent successfully');
        print('Response: ${response.body}');
        // Show a success dialog
      } else {
        // Error sending data to the API
        print('Error sending data');
      }
    });

    // Assuming the registration is successful, update the state
    setState(() {
      isRegistered = true;
    });
    // After successful registration, navigate to OtpScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(mobile: mobileNumber),
      ),
    );
  }

  // API Call End

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Blood Donor Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign the form key
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 0, 149, 0)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Blood Group*',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedBloodGroup.isEmpty)
                        Text(
                          'Blood Group is required',
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 10),
                      TypeAheadFormField<String?>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: TextEditingController(
                              text: selectedBloodGroup), // Set the controller
                          decoration: InputDecoration(
                            labelText: 'Select Blood Group',
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return bloodGroups.where((bloodGroup) => bloodGroup
                              .toLowerCase()
                              .contains(pattern.toLowerCase()));
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion!),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            selectedBloodGroup = suggestion!;
                          });
                        },
                        // enabled:areInputFieldsEnabled,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Blood Group is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Name*',
                  ),
                  // enabled: areInputFieldsEnabled,
                  validator: (value) {
                    if (name.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      designation = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Designation*',
                  ),
                  // enabled: areInputFieldsEnabled,
                  validator: (value) {
                    if (designation.isEmpty) {
                      return 'Designation is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 0, 149, 0)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Office Address*',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  officeStreet = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Street/Road*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officeStreet.isEmpty) {
                                  return 'Street/Road is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  officeArea = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Area/Locality*',
                              ),
                              // enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officeArea.isEmpty) {
                                  return 'Area/Locality is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  officeDistrict = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'District*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officeDistrict.isEmpty) {
                                  return 'District is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  officeState = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'State*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officeState.isEmpty) {
                                  return 'State is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  officeCity = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'City*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officeCity.isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  officePincode = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Pincode*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (officePincode.isEmpty) {
                                  return 'Pincode is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            officeCountry = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Country*',
                        ),
                        controller: TextEditingController(
                            text: 'India'), // Set default value
                        enabled: false, // Disable the text field
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Office Latitude*',
                              ),
                              controller: officeLatitudeController,
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Office Longitude*',
                              ),
                              controller: officeLongitudeController,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 0, 149, 0)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Residential Address*',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  street1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Street/Road*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (street1.isEmpty) {
                                  return 'Street/Road is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  area1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Area/Locality*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (area1.isEmpty) {
                                  return 'Area/Locality is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  district1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'District*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (district1.isEmpty) {
                                  return 'District is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  state1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'State*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (state1.isEmpty) {
                                  return 'State is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  city1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'City*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (city1.isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                getAddressCoordinates();
                                setState(() {
                                  pincode1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Pincode*',
                              ),
                              //  enabled: areInputFieldsEnabled,
                              validator: (value) {
                                if (pincode1.isEmpty) {
                                  return 'Pincode is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            country1 = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Country*',
                        ),
                        controller: TextEditingController(
                            text: 'India'), // Set default value
                        enabled: false, // Disable the text field
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Residential Latitude*',
                              ),
                              controller: residentialLatitudeController,
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Residential Longitude*',
                              ),
                              controller: residentialLongitudeController,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      mobileNumber = value;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number*',
                  ),
                  //  enabled: areInputFieldsEnabled,
                  validator: (value) {
                    if (mobileNumber.isEmpty) {
                      return 'Mobile Number is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (password.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: false,
                  validator: (value) {
                    if (confirmPassword.isEmpty) {
                      return 'Confirm Password is required';
                    } else if (confirmPassword != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: registerDonor,
                  child: const Text('Register'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String mobile;
  const OtpScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  String otp = '';

  void verifyOTP() {
    // Replace this logic with your actual OTP verification process
    if (otp == '1234') {
      // If OTP is valid, you can use widget.mobileNumber here
      // For example, print the mobile number
      print('Mobile Number: ${widget.mobile}');

      // Then you can navigate to the next screen (e.g., HomePage)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Handle incorrect OTP
      // Show an error message or allow the user to retry
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
            key: _formKey, // Assign the form key
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
                const SizedBox(
                    height: 10), // Display OTP input fields if registered
                Column(
                  children: [
                    Text(
                      'Please enter the OTP sent to your mobile number',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          otp = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Enter OTP'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        verifyOTP();
                      },
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
