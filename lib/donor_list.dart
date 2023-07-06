
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:share/share.dart';
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
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    donorData = fetchData();
    print(widget.bloodGroup);
    print(widget.state);
    print(widget.district);
    print(widget.city);
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final url = base_url +'donor_list1';
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
    final itemMobileNo = item['mobile_no'] as String?;
    final itemDesig = item['desig'] as String?;
    final itemOfficeCity = item['office_city'] as String?;

    final cardDetails = '''
    Name: $itemName
    Mobile No: $itemMobileNo
    Designation: $itemDesig
    Office City: $itemOfficeCity
  ''';

    return cardDetails;
  }

  void _shareCardDetails(String cardDetails) {
    Share.share(cardDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donors List'),
      ),
      body: Container(
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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        bool isExpanded = isExpandedList[index];
                        final itemName = item['name'] as String?;
                        final itemMobileNo = item['mobile_no'] as String?;
                        final itemDesig = item['desig'] as String?;
                        final itemOfficeCity = item['office_city'] as String?;

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      itemMobileNo ?? '',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      ),
                                    ),
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
    );
  }
}
