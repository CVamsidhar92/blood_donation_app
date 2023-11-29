import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  String mobileNo;
  EditProfile({Key? key, required this.mobileNo}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Container(),
    );
  }
}
