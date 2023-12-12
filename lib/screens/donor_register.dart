import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

// Define a stateful widget for the registration screen
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

// Define the state for the registration screen
class _RegisterState extends State<Register> {
    // Key to uniquely identify the Form widget
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Declare variables to store user input data
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
  double? officeLatitude;
  double? officeLongitude;
  double? residentialLatitude;
  double? residentialLongitude;
  bool isRegistered = false;
  bool areInputFieldsEnabled = true; // Add this variable
  String password = '';
  String confirmPassword = '';
  bool _passwordObscureText = true;

  // List of blood groups
  List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

    // Controllers for latitude and longitude text fields
  TextEditingController officeLatitudeController = TextEditingController();
  TextEditingController officeLongitudeController = TextEditingController();
  TextEditingController residentialLatitudeController = TextEditingController();
  TextEditingController residentialLongitudeController = TextEditingController();
  String otp = '';

  // Function to fetch latitude and longitude from address
  Future<Map<String, double>> getLatLngFromAddress(
      String street, String area, String city, String state) async {
    final apiKey =
        'API_KEY'; // Replace with your API key
    final fullAddress = '$street, $area, $city, $state';
    final encodedAddress = Uri.encodeFull(fullAddress);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';
    
    // Make a request to the Geocoding API
    final response = await http.get(Uri.parse(url));
    // Process the API response
    if (response.statusCode == 200) {
    // Parse the response to extract latitude and longitude
      final data = json.decode(response.body);
      final results = data['results'][0];
      final location = results['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];

      print('Fetched coordinates for $fullAddress: Lat: $lat, Lng: $lng');
      return {'latitude': lat, 'longitude': lng};
    } else {
      print('Failed to fetch coordinates for $fullAddress');
    // Handle the case where fetching coordinates fails
      throw Exception('Failed to fetch coordinates');
    }
  }

  // Function to get latitude and longitude for office address
  Future<void> getAddressCoordinates() async {
    try {
  // Call the Geocoding API function for the office address
      var officeLatLng = await getLatLngFromAddress(
        officeStreet,
        officeArea,
        officeCity,
        officeState,
      );

      print('Office Latitude: ${officeLatLng['latitude']}');
      print('Office Longitude: ${officeLatLng['longitude']}');

      // Update the state with the fetched coordinates
      setState(() {
        officeLatitude = officeLatLng['latitude'] as double;
        officeLongitude = officeLatLng['longitude'] as double;
      });
     // Update the text controllers for latitude and longitude
      setState(() {
        // After setting the values in the state, you can update the controllers
        officeLatitudeController.text = officeLatitude.toString();
        officeLongitudeController.text = officeLongitude.toString();
      });
    } catch (e) {
      // Handle error
      print('Error fetching coordinates: $e');
    }
  }

  // Function to get latitude and longitude for residential address
  Future<void> getAddressCoordinates1() async {
    try {
            // Call the Geocoding API function for the residential address

      var residentialLatLng = await getLatLngFromAddress(
        street1,
        area1,
        city1,
        state1,
      );

      print('Residential Latitude: ${residentialLatLng['latitude']}');
      print('Residential Longitude: ${residentialLatLng['longitude']}');

      // Update the state with the fetched coordinates
      setState(() {
        residentialLatitude = residentialLatLng['latitude'] as double;
        residentialLongitude = residentialLatLng['longitude'] as double;
      });
            // Update the text controllers for latitude and longitude
      setState(() {
        residentialLatitudeController.text = residentialLatitude.toString();
        residentialLongitudeController.text = residentialLongitude.toString();
      });
    } catch (e) {
           // Handle error if fetching coordinates fails
      print('Error fetching coordinates: $e');
    }
  }

  // Function to handle the registration process
  void registerDonor() async {
    // Call functions to fetch latitude and longitude for both addresses
   await getAddressCoordinates();
  await getAddressCoordinates1();

    // Validate the form using the form key
    if (!_formKey.currentState!.validate()) {
      // Form validation failed, do not proceed with the API call
      return;
    }

    // Check if any of the location coordinates is null
    if (!(officeLatitude != null &&
        officeLongitude != null &&
        residentialLatitude != null &&
        residentialLongitude != null)) {
                // Display an error message if coordinates are null
    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Ensure the address entered is accurate.'),
    backgroundColor: Colors.red, // Set the background color to red
  ),
);
      return;
    }
    // Check if the user already exists based on mobile number
    bool isUserExists = await checkUserExistence();

    if (isUserExists) {
            // Display a message if the user already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mobile number is already registered, Please Login.'),
        ),
      );
      return;
    }
    // map to hold the form data
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
        builder: (context) =>
            OtpScreen(mobile: mobileNumber, name: name, password: password),
      ),
    );
  }

// Function to check if the user already exists based on the mobile number
  Future<bool> checkUserExistence() async {
    // Make a request to your backend to check if the user exists
    Uri checkUrl = Uri.parse(base_url + 'checkUser');
    http.Response checkResponse = await http.post(checkUrl, body: {
      'mobileNumber': mobileNumber,
    });

    if (checkResponse.statusCode == 200) {
      // Parse the response to determine if the user exists
      Map<String, dynamic> responseData = json.decode(checkResponse.body);
      String status = responseData['status'];
      return status == 'Duplicate';
    } else {
      // Handle the error or assume the user doesn't exist
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Blood Donor Registration', style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
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
                      Center(
                        child: const Text(
                          'Office Address*',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '(Kindly ensure the address is provided accurately)',
                          style: TextStyle(fontSize: 15, color: Colors.red),
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
                                  getAddressCoordinates();
                              },
                              decoration: InputDecoration(
                                labelText: 'Street/Road*',
                              ),
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
                                      getAddressCoordinates();
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
                                  officeCity = value;
                                });
                                 getAddressCoordinates();
                              },
                              decoration: InputDecoration(
                                labelText: 'City*',
                              ),
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
                              onChanged: (value) {
                               
                                setState(() {
                                  officeDistrict = value;
                                });
                                 getAddressCoordinates();
                              },
                              decoration: InputDecoration(
                                labelText: 'District*',
                              ),
                              validator: (value) {
                                if (officeDistrict.isEmpty) {
                                  return 'District is required';
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
                                  officeState = value;
                                });
                                    getAddressCoordinates();
                              },
                              decoration: InputDecoration(
                                labelText: 'State*',
                              ),
                              validator: (value) {
                                if (officeState.isEmpty) {
                                  return 'State is required';
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
                                  officePincode = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Pincode*',
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6)
                              ],
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
                      Center(
                        child: const Text(
                          'Residential Address*',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '(Kindly ensure the address is provided accurately)',
                          style: TextStyle(fontSize: 15, color: Colors.red),
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
                                 getAddressCoordinates1();
                              },
                              decoration: InputDecoration(
                                labelText: 'Street/Road*',
                              ),
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
                                  getAddressCoordinates1();
                              },
                              decoration: InputDecoration(
                                labelText: 'Area/Locality*',
                              ),
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
                                  city1 = value;
                                });
                                   getAddressCoordinates1();
                              },
                              decoration: InputDecoration(
                                labelText: 'City*',
                              ),
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
                              onChanged: (value) {
                               
                                setState(() {
                                  district1 = value;
                                });
                                 getAddressCoordinates1();
                              },
                              decoration: InputDecoration(
                                labelText: 'District*',
                              ),
                              validator: (value) {
                                if (district1.isEmpty) {
                                  return 'District is required';
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
                                  state1 = value;
                                });
                                 getAddressCoordinates1();
                              },
                              decoration: InputDecoration(
                                labelText: 'State*',
                              ),
                              validator: (value) {
                                if (state1.isEmpty) {
                                  return 'State is required';
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
                                getAddressCoordinates1();
                                setState(() {
                                  pincode1 = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Pincode*',
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6)
                              ],
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
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
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
                  obscureText: _passwordObscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    // else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:;<>,.?~\\-])').hasMatch(value)) {
                    //   return 'must contain uppercase, lowercase, digit, and one special character';
                    // }
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
  style: ElevatedButton.styleFrom(
    primary: Colors.blue, // Set background color to blue
    onPrimary: Colors.white, // Set text color to white
  ),
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
