import 'dart:convert';
import 'dart:math';
import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:share/share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base_url.dart';

// Define the stateful widget for the DonorListScreen
class DonorListScreen extends StatefulWidget {
  final String bloodGroup;
  final String mobileNo;
  final String role;

  DonorListScreen(
      {Key? key,
      required this.bloodGroup,
      required this.mobileNo,
      required this.role})
      : super(key: key);

  @override
  _DonorListScreenState createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  late Future<List<Map<String, dynamic>>> donorData;
  String selectedDistance = '5kms'; // Initially, select '5kms'
  List<bool> isExpandedList = [];
  double? latitude;
  double? longitude;

// Distance options for the user to choose from
  final Map<String, String> distanceOptions = {
    '5kms': '5kms',
    '10kms': '10kms',
  };

 // Get the label for the currently selected distance
  String getSelectedLabel() {
    return distanceOptions[selectedDistance] ?? '';
  }
// Set the selected distance based on the label
  void setSelectedValue(String label) {
    final matchingEntry = distanceOptions.entries.firstWhere(
      (entry) => entry.value == label,
      orElse: () => MapEntry('5kms', '5kms'),
    );
    selectedDistance = matchingEntry.key;
  }
 // Initialize the state
  @override
  void initState() {
    super.initState();
    requestLocationPermissionAndGetCurrentLocation();
    // getCurrentLocation();
    print(widget.bloodGroup);
  }
 // Calculate the distance between two geographical points using Haversine formula
  double calculateDistance(
      double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      // Handle cases where latitude or longitude is null
      return double.infinity; // Or any other appropriate value
    }

    const double earthRadius = 6371;
    final double dLat = _radians(lat2 - lat1);
    final double dLon = _radians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(lat1)) *
            cos(_radians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

 // Convert degrees to radians
  double _radians(double degrees) {
    return degrees * pi / 180;
  }

 // Request location permission and get the current location
  Future<void> requestLocationPermissionAndGetCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await getCurrentLocation();
      setState(() {
        if (mounted) {
          latitude = position?.latitude;
          longitude = position?.longitude;
        }
      });

      if (latitude != null && longitude != null) {
        print('Latitude: $latitude, Longitude: $longitude');
      }
    } else if (status.isDenied) {
      // Handle denied permission
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied permission
      openAppSettings();
    }
  }

// Get the current location using the Geolocator package
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

 // Fetch donor data from the API based on the selected distance
  Future<List<Map<String, dynamic>>> fetchData(double selectedDistance) async {
    final url = base_url + 'donor_list1';
    final body = {
      'bloodGroup': widget.bloodGroup,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);

          // Ensure latitude and longitude are part of the data
          data.forEach((item) {
            item['officeLatitude'] =
                parseDouble(item['office_latitude'] as String?);
            item['officeLongitude'] =
                parseDouble(item['office_longitude'] as String?);
            item['residentialLatitude'] =
                parseDouble(item['residential_latitude'] as String?);
            item['residentialLongitude'] =
                parseDouble(item['residential_longitude'] as String?);
          });

          // Filter data based on selected distance
          final filteredData = data.where((item) {
            final officeLat = item['officeLatitude'] as double?;
            final officeLon = item['officeLongitude'] as double?;
            final resLat = item['residentialLatitude'] as double?;
            final resLon = item['residentialLongitude'] as double?;

            if (officeLat != null &&
                officeLon != null &&
                resLat != null &&
                resLon != null &&
                latitude != null &&
                longitude != null) {
              final officeDistance = calculateDistance(
                  latitude!, longitude!, officeLat, officeLon);
              final resDistance =
                  calculateDistance(latitude!, longitude!, resLat, resLon);

              // Check if the donor is within the selected distance (5kms or 10kms)
              return officeDistance <= 10.0 || resDistance <= 10.0;
            } else {
              return false;
            }
          }).toList();

          isExpandedList = List<bool>.filled(filteredData.length, false);
          return filteredData;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data from API: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to fetch data from API: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return [];
    }
  }

   // Launch a phone call using the FlutterPhoneDirectCaller package

  void _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber != null) {
      try {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to make a phone call.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
// Build the detailed card details as a string for sharing
  String buildCardDetails(Map<String, dynamic> item) {
    final itemName = item['name'] as String?;
    final itemBloodGroup = item['blood_group'] as String?;
    final itemMobileNo = item['mobile_no'] as String?;
    final itemDesig = item['desig'] as String?;
    final itemOffAddress1 = item['office_street'] as String?;
    final itemOffAddress2 = item['office_area'] as String?;
    final itemOffCity = item['office_city'] as String?;
    final itemResAddress1 = item['residential_street'] as String?;
    final itemResAddress2 = item['residential_area'] as String?;
    final itemResCity = item['residential_city'] as String?;

    final cardDetails = '''
    Name:- $itemName    
    Blood Group:- $itemBloodGroup
    Mobile No:- $itemMobileNo
    Designation:- $itemDesig
    Office Address:- $itemOffAddress1 , $itemOffAddress2 , $itemOffCity
    Residential Address:- $itemResAddress1 , $itemResAddress2 , $itemResCity
  ''';

    return cardDetails;
  }
  // Share the detailed card details
  void _shareCardDetails(String cardDetails) {
    Share.share(cardDetails);
  }
  
// Build the UI for the DonorListScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Donors List',
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
                      Login(), // Replace with the actual login screen widget
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: distanceOptions.keys.map((option) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDistance = option;
                        });
                      },
                      child: Row(
                        children: [
                          Radio(
                            value: option,
                            groupValue: selectedDistance,
                            onChanged: (value) {
                              setState(() {
                                selectedDistance = value.toString();
                              });
                            },
                          ),
                          Text(distanceOptions[option]!),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData(
                  double.parse(selectedDistance.replaceAll('kms', ''))),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a loading indicator while waiting for data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    // Display an error message if an error occurred
                    return Center(
                      child: Text(
                        'Error fetching data: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    final data = snapshot.data!;
                    final filteredData = selectedDistance == '5kms' ||
                            selectedDistance == '10kms'
                        ? data
                        : data.where((item) {
                            final officeLat = item['officeLatitude'] as double?;
                            final officeLon =
                                item['officeLongitude'] as double?;
                            final resLat =
                                item['residentialLatitude'] as double?;
                            final resLon =
                                item['residentialLongitude'] as double?;

                            if (officeLat != null &&
                                officeLon != null &&
                                resLat != null &&
                                resLon != null &&
                                latitude != null &&
                                longitude != null) {
                              final officeDistance = calculateDistance(
                                  latitude!, longitude!, officeLat, officeLon);
                              final resDistance = calculateDistance(
                                  latitude!, longitude!, resLat, resLon);

                              final maxDistance = double.parse(
                                  selectedDistance.replaceAll('kms', ''));
                              return officeDistance <= maxDistance ||
                                  resDistance <= maxDistance;
                            } else {
                              return false;
                            }
                          }).toList();

                    isExpandedList =
                        List<bool>.filled(filteredData.length, false);

                    if (filteredData.isEmpty) {
                      return Center(
                        child: Text(
                          'No Donors Found within the specified distance.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          print('Building card for item at index $index');
                          final item = filteredData[index];
                          print('Item: $item');
                          // Check if the widget's mobile number is the same as the item's mobile number
                          if (widget.mobileNo == item['mobile_no']) {
                            // Do not display the card
                            return SizedBox
                                .shrink(); // This will create an empty, non-visible widget
                          }
                          return Card(
                            child: Stack(
                              children: [
                                ExpansionTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${item['name'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        'Mobile : ${item['mobile_no'] ?? ''}',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'Desig: ${item['desig'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            'Office: ${item['office_city'] ?? ''}',
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Res: ${item['residential_city'] ?? ''}',
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.call),
                                            onPressed: () {
                                              _launchPhoneCall(
                                                  item['mobile_no'] as String?);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.share),
                                            onPressed: () {
                                              final cardDetails =
                                                  buildCardDetails(item);
                                              _shareCardDetails(cardDetails);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onExpansionChanged: (expanded) {
                                    // Handle expansion changes if needed
                                  },
                                  initiallyExpanded: isExpandedList[index],
                                ),
                                Positioned(
                                  bottom: 4.0,
                                  right: 4.0,
                                  child: Text(
                                    '${calculateDistance(
                                      latitude,
                                      longitude,
                                      item['officeLatitude'] as double?,
                                      item['officeLongitude'] as double?,
                                    ).toStringAsFixed(2)} kms',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                } else {
                  // Handle other connection states if needed
                  return const SizedBox.shrink(); // or another widget
                }
              },
            ),
          ))
        ]));
  }
}

double? parseDouble(String? value) {
  if (value == null) return null;
  return double.tryParse(value);
}
