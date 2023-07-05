import 'package:blood_donation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  String name = '';
  String selectedBloodGroup = '';
  String designation = '';
  String officeArea = '';
  String officeStreet = '';
  String officeCity = '';
  String officePincode = '';
  String? officeDistrict = '';
  String? officeState = '';
  String officeCountry = 'India';
  String area1 = '';
  String street1 = '';
  String city1 = '';
  String pincode1 = '';
  String? district1 = '';
  String? state1 = '';
  String mobileNumber = '';
  String country1 = 'India';

  bool isDistrictEnabled = false;

  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  TextEditingController stateController1 = TextEditingController();
  TextEditingController districtController1 = TextEditingController();
  TextEditingController cityController1 = TextEditingController();
  

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

  List<String> districts = [];
  List<dynamic> data = [];
  String selectedCity = '';
  String selectedCity1 = '';
  @override
  void initState() {
    super.initState();
    officeDistrict = districts[0];
    fetchCities(); // Fetch cities and populate the list
  }

 Future<void> fetchCities() async {
  final res = await http.post(
    Uri.parse("https://bzadevops.co.in/BloodDonationApp/api/getCityName"),
    // You can pass any necessary headers or request body here
  );
  if (res.statusCode == 200) {
    final fetchedData = jsonDecode(res.body);
    if (fetchedData is List) {
      setState(() {
        data.addAll(fetchedData);
      });
    }
  } else {
    // Handle the error case
    print('Failed to fetch data');
  }
}


  List<String> cities = [];

  //Call API Start
  void registerDonor() {
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
    };

    // Convert the form data to JSON
    String jsonData = jsonEncode(formData);

    // Make a POST request to the API endpoint
    Uri url =
        Uri.parse('https://bzadevops.co.in/BloodDonationApp/api/register');
    http.post(url,
        body: jsonData,
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 200) {
        // Data successfully sent to the API
        print('Data sent successfully');
        print('Response: ${response.body}');
        // Show a success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Data submitted successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog

                    // Navigate to another screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Error sending data to the API
        print('Error sending data');
      }
    });
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
                      'Blood Group',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    designation = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Designation',
                ),
              ),
              const SizedBox(height: 10),

              //Office Address

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
                      'Office Address',
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
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                officeArea = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Address 1',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                officeStreet = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Address 2',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Cities Dropdown
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width:
                            300, // Set the desired width for the district dropdown
                        child: TypeAheadFormField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Select a City',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCity =
                                        ''; // Clear the selected station
                                  });
                                },
                                child: Icon(Icons.close), // Close icon button
                              ),
                            ),
                            controller:
                                TextEditingController(text: selectedCity),
                          ),
                          suggestionsCallback: (pattern) async {
                            await Future.delayed(Duration(seconds: 1));

                            return data
                                .map<String>((item) => item['city'].toString())
                                .where((city) => city
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              selectedCity = suggestion;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a City';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                officeDistrict = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'District',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                               officeState = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child:  TextField(
                      onChanged: (value) {
                        setState(() {
                          officeCountry = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Country',
                      ),
                      controller: TextEditingController(
                          text: 'India'), // Set default value
                      enabled: false, // Disable the text field
                    ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                officePincode = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Pincode',
                            ),
                          ),
                        ),
                      ],
                    ),

                   
                  ],
                ),
              ),
              const SizedBox(height: 20),

// Residential Address

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
                      'Residential Address',
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
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                area1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Address 1',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                street1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Address 2',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Cities Dropdown
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width:
                            300, // Set the desired width for the district dropdown
                        child: TypeAheadFormField<String>(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Select a City',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCity1 =
                                        ''; // Clear the selected station
                                  });
                                },
                                child: Icon(Icons.close), // Close icon button
                              ),
                            ),
                            controller:
                                TextEditingController(text: selectedCity1),
                          ),
                          suggestionsCallback: (pattern) async {
                            await Future.delayed(Duration(seconds: 1));

                            return data
                                .map<String>((item) => item['city'].toString())
                                .where((city) => city
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            setState(() {
                              selectedCity1 = suggestion;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a City';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                district1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'District',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                state1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                pincode1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Pincode',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                country1 = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Country',
                            ),
                            controller: TextEditingController(
                                text: 'India'), // Set default value
                            enabled: false, // Disable the text field
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    mobileNumber = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerDonor,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
