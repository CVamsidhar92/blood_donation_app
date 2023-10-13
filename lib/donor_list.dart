import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:share/share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base_url.dart';

class DonorListScreen extends StatefulWidget {
  final String? bloodGroup;
  final String? state;
  final String? district;
  final String city;

  DonorListScreen({
    Key? key,
    required this.bloodGroup,
    required this.state,
    required this.district,
    required this.city,
  }) : super(key: key);

  @override
  _DonorListScreenState createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  late Future<List<Map<String, dynamic>>> donorData;
  String selectedDistance = '5kms'; // Initially, select '5kms'
  List<bool> isExpandedList = [];
  double? latitude;
  double? longitude;

  final Map<String, String> distanceOptions = {
    '5kms': '5kms',
    '10kms': '10kms',
  };

  String getSelectedLabel() {
    return distanceOptions[selectedDistance] ?? '';
  }

  void setSelectedValue(String label) {
    final matchingEntry = distanceOptions.entries.firstWhere(
      (entry) => entry.value == label,
      orElse: () => MapEntry('5kms', '5kms'),
    );
    selectedDistance = matchingEntry.key;
  }

  @override
  void initState() {
    super.initState();
    donorData = fetchData();
    requestLocationPermissionAndGetCurrentLocation();
  }

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

  double _radians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> requestLocationPermissionAndGetCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await getCurrentLocation();
      setState(() {
        latitude = position?.latitude;
        longitude = position?.longitude;
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

  Future<List<Map<String, dynamic>>> fetchData() async {
    final url = base_url + 'donor_list1';
    final body = {
      'bloodGroup': widget.bloodGroup ?? '',
      'state': widget.state ?? '',
      'district': widget.district ?? '',
      'city': widget.city,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);
          isExpandedList = List<bool>.filled(data.length, false);
          return data;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
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

    final cardDetails =
        '''
    Name:- $itemName    
    Blood Group:- $itemBloodGroup
    Mobile No:- $itemMobileNo
    Designation:- $itemDesig
    Office Address:- $itemOffAddress1 , $itemOffAddress2 , $itemOffCity
    Residential Address:- $itemResAddress1 , $itemResAddress2 , $itemResCity
  ''';

    return cardDetails;
  }

  void _shareCardDetails(String cardDetails) {
    Share.share(cardDetails);
  }

  double? parseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donors List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: distanceOptions.keys.map((option) {
                return Row(
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
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: donorData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error fetching data: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Donors Found.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    final data = snapshot.data!;
                    final filteredData = selectedDistance == '10kms'
                        ? data
                        : data.where((item) {
                            final officeLat =
                                parseDouble(item['office_latitude'] as String?);
                            final officeLon = parseDouble(
                                item['office_longitude'] as String?);
                            final resLat = parseDouble(
                                item['residential_latitude'] as String?);
                            final resLon = parseDouble(
                                item['residential_longitude'] as String?);

                            if (officeLat != null &&
                                officeLon != null &&
                                latitude != null &&
                                longitude != null) {
                              final distance = calculateDistance(
                                  latitude!, longitude!, officeLat, officeLon);
                              return distance <=
                                  10.0; // Adjust this value as needed
                            } else if (resLat != null &&
                                resLon != null &&
                                latitude != null &&
                                longitude != null) {
                              final distance = calculateDistance(
                                  latitude!, longitude!, resLat, resLon);
                              return distance <=
                                  10.0; // Adjust this value as needed
                            } else {
                              return false;
                            }
                          }).toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];
                              bool isExpanded = isExpandedList[index];
                              final itemName = item['name'] as String?;
                              final itemMobileNo = item['mobile_no'] as String?;
                              final itemDesig = item['desig'] as String?;
                              final itemOfficeCity =
                                  item['office_city'] as String?;

                              return Card(
                                child: ExpansionTile(
                                  title: Column(
                                    children: [
                                      Text(
                                        itemName ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        itemMobileNo ?? '',
                                        textAlign: TextAlign.center,
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
                                        itemDesig ?? '',
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
                                            itemOfficeCity ?? '',
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
                                    setState(() {
                                      isExpandedList[index] = expanded;
                                    });
                                  },
                                  initiallyExpanded: isExpanded,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
