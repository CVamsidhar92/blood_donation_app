// import 'package:blood_donation/screens/donor_list.dart';
// import 'package:blood_donation/screens/login.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'base_url.dart';

// class FindDonor extends StatefulWidget {
//   @override
//   _FindDonorState createState() => _FindDonorState();
// }

// class _FindDonorState extends State<FindDonor> {
//   int currentStep = 0;
//   String? selectedBloodGroup;
//   String? selectedState;
//   String? selectedDistrict;
//   String? selectedCity;

//   List<String> bloodGroups = [
//     'A+',
//     'A-',
//     'B+',
//     'B-',
//     'AB+',
//     'AB-',
//     'O+',
//     'O-',
//     'A1+',
//     'A1-',
//     'A2+',
//     'A2-',
//     'A1B+',
//     'A1B-',
//     'A2B+',
//     'A2B-'
//   ];

//   List<dynamic> data = [];
//   List<String> states = [];
//   List<String> districts = [];
//   List<String> cities = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchCities(); // Fetch cities and populate the lists
//   }

//   Future<void> fetchCities() async {
//     final res = await http.post(
//       Uri.parse(base_url + 'getCityName'),
//       // You can pass any necessary headers or request body here
//     );
//     if (res.statusCode == 200) {
//       final fetchedData = jsonDecode(res.body);
//       if (fetchedData is List) {
//         setState(() {
//           data.addAll(fetchedData);
//           states =
//               data.map((item) => item['state'].toString()).toSet().toList();
//           selectedState = states.isNotEmpty ? states[0] : null;
//           updateDistrictsAndCities();
//         });
//       }
//     } else {
//       // Handle the error case
//       print('Failed to fetch data');
//     }
//   }

//   void updateDistrictsAndCities() {
//     final filteredData = data
//         .where((item) => item['state'].toString() == selectedState!)
//         .toList();
//     districts = filteredData
//         .map((item) => item['district'].toString())
//         .toSet()
//         .toList();
//     selectedDistrict = districts.isNotEmpty ? districts[0] : null;
//     updateCities();
//   }

//   void updateCities() {
//     if (selectedState != null && selectedDistrict != null) {
//       final filteredData = data
//           .where(
//             (item) =>
//                 item['state'].toString() == selectedState! &&
//                 item['district'].toString() == selectedDistrict!,
//           )
//           .toList();
//       cities = filteredData.map((item) => item['city'].toString()).toList();
//       selectedCity = cities.isNotEmpty ? cities[0] : null;
//     } else {
//       cities = [];
//       selectedCity = null;
//     }
//   }

//   void navigateToDonorList() {
//     if (selectedBloodGroup != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DonorListScreen(
//             bloodGroup: selectedBloodGroup!,
//             state: selectedState ?? '',
//             district: selectedDistrict ?? '',
//             city: selectedCity ?? '',
//           ),
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Validation Error'),
//             content: Text('Please select a blood group.'),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Find A Donor'),
//         actions: <Widget>[
//           InkWell(
//             onTap: () {
//               Navigator.of(context).pushReplacement(MaterialPageRoute(
//                 builder: (context) =>
//                     Login(), // Replace with the actual login screen widget
//               ));
//             },
//             child: Row(
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.only(right: 8.0),
//                   child: Icon(
//                     Icons.logout_outlined,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(right: 20.0),
//                   child: Text(
//                     'Logout',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Stepper(
//                 currentStep: currentStep,
//                 onStepContinue: () {
//                   if (currentStep == 3) {
//                     // Perform the search or save the data
//                     // Replace this with your actual code
//                     //  print('Blood group: $selectedBloodGroup');
//                     //print('State: $selectedState');
//                     //print('District: $selectedDistrict');
//                     //print('City: $selectedCity');
//                   }
//                   setState(() {
//                     if (currentStep < 3) {
//                       currentStep += 1;
//                     }
//                   });
//                 },
//                 onStepCancel: () {
//                   setState(() {
//                     if (currentStep > 0) {
//                       currentStep -= 1;
//                     }
//                   });
//                 },
//                 steps: [
//                   Step(
//                     title: const Text('Select Blood Group'),
//                     isActive: currentStep == 0,
//                     content: DropdownButtonFormField<String>(
//                       value: selectedBloodGroup,
//                       items: bloodGroups.map((String bloodGroup) {
//                         return DropdownMenuItem<String>(
//                           value: bloodGroup,
//                           child: Text(bloodGroup),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedBloodGroup = newValue;
//                           selectedState = null;
//                           selectedDistrict = null;
//                           selectedCity = null;
//                         });
//                       },
//                     ),
//                   ),
//                   Step(
//                     title: const Text('Select State'),
//                     isActive: currentStep == 1,
//                     content: DropdownButtonFormField<String>(
//                       value: selectedState,
//                       items: [
//                         ...states.map((String state) {
//                           return DropdownMenuItem<String>(
//                             value: state,
//                             child: Text(state),
//                           );
//                         }).toList(),
//                       ],
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedState = newValue;
//                           updateDistrictsAndCities();
//                         });
//                       },
//                     ),
//                   ),
//                   Step(
//                     title: const Text('Select District'),
//                     isActive: currentStep == 2,
//                     content: DropdownButtonFormField<String>(
//                       value: selectedDistrict ??
//                           'All', // Set initial value to 'All' if selectedDistrict is null
//                       items: [
//                         DropdownMenuItem<String>(
//                           value: 'All',
//                           child: Text('All'),
//                         ),
//                         ...districts.map((String district) {
//                           return DropdownMenuItem<String>(
//                             value: district,
//                             child: Text(district),
//                           );
//                         }).toList(),
//                       ],
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedDistrict = newValue;
//                           updateCities();
//                         });
//                       },
//                     ),
//                   ),
//                   Step(
//                     title: const Text('Select City'),
//                     isActive: currentStep == 3,
//                     content: DropdownButtonFormField<String>(
//                       value: selectedCity,
//                       items: [
//                         DropdownMenuItem<String>(
//                           value: null,
//                           child: Text('All'),
//                         ),
//                         ...cities.map((String city) {
//                           return DropdownMenuItem<String>(
//                             value: city,
//                             child: Text(city),
//                           );
//                         }).toList(),
//                       ],
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedCity = newValue;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: navigateToDonorList,
//               child: const Text('Search'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
