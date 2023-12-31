import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/home_page.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

// Define the Edit Profile widget

class EditProfile extends StatefulWidget {
    // Declare variables for user mobile number and role
  final String mobileNo;
  final String role;
    // Constructor to initialize the variables
  const EditProfile({Key? key, required this.mobileNo,required this.role}) : super(key: key);

  // Create the state for the Edit Profile page
  @override
  State<EditProfile> createState() => _EditProfileState();
}

// Define the state for the Edit Profile Page
class _EditProfileState extends State<EditProfile> {

    // Declare variables and keys
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
  double? officeLatitude;
  double? officeLongitude;
  double? residentialLatitude;
  double? residentialLongitude;
  bool isRegistered = false;
  bool areInputFieldsEnabled = true; // Add this variable
  String password = '';
  String confirmPassword = '';
  bool isLoading = true;

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

  //Editing Controllers for office latitude, Longitude and Residential Latitude and longitude
  TextEditingController officeLatitudeController = TextEditingController();
  TextEditingController officeLongitudeController = TextEditingController();
  TextEditingController residentialLatitudeController = TextEditingController();
  TextEditingController residentialLongitudeController = TextEditingController();


  // Initialize the state
  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    fetchData();
  }

  // Function to fetch latitude and longitude from address
  Future<Map<String, double>> getLatLngFromAddress(
      String street, String area, String city, String state) async {
    final apiKey =
        'AIzaSyAC2MG5XPZdHjahoQCi8mZawbB3VHbrfC0'; // Replace with your API key
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

  // Call this function to get latitude and longitude for Office addresses
  Future<void> getAddressCoordinates() async {
    try {
      var officeLatLng = await getLatLngFromAddress(
        officeStreet,
        officeArea,
        officeCity,
        officeState,
      );

      print('Office Latitude: ${officeLatLng['latitude']}');
      print('Office Longitude: ${officeLatLng['longitude']}');

      // Set the text controllers after coordinates have been fetched
      setState(() {
        officeLatitude = officeLatLng['latitude'] as double;
        officeLongitude = officeLatLng['longitude'] as double;
      });
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

  // Call this function to get latitude and longitude for Residential addresses
  Future<void> getAddressCoordinates1() async {
    try {
      var residentialLatLng = await getLatLngFromAddress(
        street1,
        area1,
        city1,
        state1,
      );

      print('Residential Latitude: ${residentialLatLng['latitude']}');
      print('Residential Longitude: ${residentialLatLng['longitude']}');

      // Set the text controllers after coordinates have been fetched
      setState(() {
        residentialLatitude = residentialLatLng['latitude'] as double;
        residentialLongitude = residentialLatLng['longitude'] as double;
      });
      setState(() {
        residentialLatitudeController.text = residentialLatitude.toString();
        residentialLongitudeController.text = residentialLongitude.toString();
      });
    } catch (e) {
      // Handle error
      print('Error fetching coordinates: $e');
    }
  }

//To fetch the profile data 
  Future<void> fetchData() async {
    try {
      // Prepare the data to be sent in the request body
      final requestData = {
        'mobileNo': widget.mobileNo,
        // Add other necessary parameters
      };

      // Make an HTTP POST request to your API endpoint
      final response = await http.post(
        Uri.parse(base_url + 'getProfile'),
        body: json.encode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse the response body (assuming it's JSON)
        final dynamic responseData = json.decode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          final firstObject = responseData[0];

          if (firstObject is Map<String, dynamic>) {
            if (firstObject.containsKey('mobile_no')) {
              setState(() {
                name = firstObject['name'];
                selectedBloodGroup = firstObject['blood_group'];
                designation = firstObject['desig'];
                officeStreet = firstObject['office_street'];
                officeArea = firstObject['office_area'];
                officeCity = firstObject['office_city'];
                officeDistrict = firstObject['office_district'];
                officeState = firstObject['office_state'];
                officePincode = firstObject['office_pincode'];
                street1 = firstObject['residential_street'];
                area1 = firstObject['residential_area'];
                city1 = firstObject['residential_city'];
                district1 = firstObject['residential_district'];
                state1 = firstObject['residential_state'];
                pincode1 = firstObject['residential_pincode'];
                mobileNumber = firstObject['mobile_no'];
              });

              // Fetch coordinates for both addresses
              await getAddressCoordinates();
              await getAddressCoordinates1();
            } else {
              print('Invalid response format: Missing expected fields.');
              print('Response Body: $firstObject');
            }
          } else {
            print('Invalid response format: Not a Map.');
            print('Response Body: $firstObject');
          }
        } else {
          print('Invalid response format: Empty list or not a list.');
          print('Response Body: $responseData');
        }
      } else {
        // Handle errors if the request was not successful
        print('Failed to fetch user data: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle exceptions
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void editProfile() async {
    if (!_formKey.currentState!.validate()) {
      // Form validation failed, do not proceed with the API call
      return;
    }

    // Check if any of the location coordinates is null
    if (!(officeLatitude != null &&
        officeLongitude != null &&
        residentialLatitude != null &&
        residentialLongitude != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ensure the address entered is accurate.'),
          backgroundColor: Colors.red, // Set the background color to red
        ),
      );
      return;
    }

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
    };

    // Convert the form data to JSON
    String jsonData = jsonEncode(formData);

    // Make a POST request to the API endpoint
    Uri url = Uri.parse(base_url + 'editProfile');
    http.post(url,
        body: jsonData,
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        // Data successfully sent to the API
        print('Data updated successfully');
        print('Response: ${response.body}');
        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green, // Set the background color to green
          ),
        );

        // Navigate to the home page after a delay (optional)
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(mobileNo: mobileNumber, role:widget.role),
            ),
          );
        });
      } else {
        // Error sending data to the API
        print('Error sending data');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
         style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    Login(), 
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Logout',
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
      body: Stack(
        children: [
          if (!isLoading) 
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Assign the form key
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Edit Donor Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 249, 28, 46),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color.fromARGB(255, 0, 149, 0)),
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
                                    text:
                                        selectedBloodGroup),
                                decoration: InputDecoration(
                                  labelText: 'Select Blood Group',
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return bloodGroups.where((bloodGroup) =>
                                    bloodGroup
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
                        initialValue: name,
                        enabled: areInputFieldsEnabled, 
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
                        initialValue: designation,
                        enabled: areInputFieldsEnabled, 
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
                          border:
                              Border.all(color: Color.fromARGB(255, 0, 149, 0)),
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
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red),
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
                                    initialValue: officeStreet,
                                    enabled:
                                        areInputFieldsEnabled,
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
                                    initialValue: officeArea,
                                    enabled:
                                        areInputFieldsEnabled,
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
                                    initialValue: officeCity,
                                    enabled:
                                        areInputFieldsEnabled, // Add this line
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
                                    onChanged: (value) {
                                      setState(() {
                                        officeDistrict = value;
                                      });
                                      getAddressCoordinates();
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'District*',
                                    ),
                                    initialValue: officeDistrict,
                                    enabled:
                                        areInputFieldsEnabled, // Add this line
                                    //  enabled: areInputFieldsEnabled,
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
                                    initialValue: officeState,
                                    enabled:
                                        areInputFieldsEnabled, // Add this line
                                    //  enabled: areInputFieldsEnabled,
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
                                      setState(() {
                                        officePincode = value;
                                      });
                                      getAddressCoordinates();
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Pincode*',
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6)
                                    ],
                                    initialValue: officePincode,
                                    enabled: areInputFieldsEnabled,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color.fromARGB(255, 0, 149, 0)),
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
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red),
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
                                    initialValue: street1,
                                    enabled: areInputFieldsEnabled,
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
                                    initialValue: area1,
                                    enabled: areInputFieldsEnabled,
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
                                    initialValue: city1,
                                    enabled: areInputFieldsEnabled,
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
                                    initialValue: district1,
                                    enabled: areInputFieldsEnabled,
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
                                    initialValue: state1,
                                    enabled: areInputFieldsEnabled,
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
                                    initialValue: pincode1,
                                    enabled: areInputFieldsEnabled,
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
                        initialValue: mobileNumber,
                        enabled: false,
                        validator: (value) {
                          if (mobileNumber.isEmpty) {
                            return 'Mobile Number is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center the buttons
                          children: [
                            ElevatedButton(
                              onPressed: editProfile,
                                style: 
                              ElevatedButton.styleFrom(
                              
                                primary: Colors.blue,
                                onPrimary: Colors.white,  // Set the background color to red
                              ),
                              child: const Text('Update'),
                            ),
                            SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context); // Navigate back when the button is pressed
                              },
                              style: 
                              ElevatedButton.styleFrom(
                              
                                primary: Colors.red,
                                onPrimary: Colors.white,  // Set the background color to red
                              ),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isLoading) // Show a loading indicator if data is still loading
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
