// Import necessary packages and files
import 'package:blood_donation/screens/admin_register.dart';
import 'package:blood_donation/screens/base_url.dart';
import 'package:blood_donation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// UsersList widget for displaying a list of users with admin functionalities
class UsersList extends StatefulWidget {
  final String role; // Role of the user, e.g., 'admin'
  UsersList({Key? key, required this.role}) : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

// _UsersListState manages the state for the UsersList widget
class _UsersListState extends State<UsersList> {
  List<dynamic> data = []; // List to store user data
  List<dynamic> filteredData = []; // List to store filtered user data
  TextEditingController searchController =
      TextEditingController(); // Controller for the search bar
  bool isLoading = true; // Flag to indicate whether data is still loading

  @override
  void initState() {
    super.initState();
    getAllUsers(); // Fetch user data when the widget is initialized
  }

  // Fetch all users from the server
  Future<void> getAllUsers() async {
    try {
      final String url = base_url + 'getusers';

      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final fetchedData = jsonDecode(res.body);

        if (fetchedData is List) {
          setState(() {
            data.addAll(fetchedData);
            filteredData.addAll(fetchedData);
            isLoading = false; // Set loading to false when data is loaded
          });
        } else {
          print('Invalid API response format: $fetchedData');
          setState(() {
            isLoading = false; // Set loading to false on error
          });
        }
      } else {
        print('Failed to fetch data. Status Code: ${res.statusCode}');
        setState(() {
          isLoading = false; // Set loading to false on error
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  // Filter users based on search query
  void filterUsers(String query) {
    setState(() {
      filteredData = data
          .where((user) =>
              user['mobile_no']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              user['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  // Delete a user item after confirmation
  Future<void> deleteItem(
      Map<String, dynamic> userData, BuildContext context) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);

    if (confirmDelete) {
      try {
        final String url = base_url + 'deleteUser';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'mobile': userData['mobile_no']}), // Pass only the user ID
        );

        if (response.statusCode == 200) {
          // Show a Snackbar to inform the user about the successful deletion.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User deleted successfully'),
            ),
          );

          // Clear existing data and fetch new data
          setState(() {
            data.clear();
            filteredData.clear();
          });

          // Fetch new data
          getAllUsers();
          // Close the keyboard
          FocusScope.of(context).unfocus();
          // Clear the search bar data
          searchController.clear();
        } else {
          print('Failed to delete data with ID ${userData['id']}');
          // Handle the error case or show an error message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to Delete User'),
            ),
          );
        }
      } catch (error) {
        print('Error: $error');
        // Handle any exceptions that may occur during the HTTP request.
      }
    }
  }

  // Show a confirmation dialog before deleting a user
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ??
        false; // Return false if the dialog is dismissed without a choice
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Users',
         style: TextStyle(
      fontWeight: FontWeight.bold, // Set text to bold
      color: Colors.white, // Set text color to white
    ),),
        actions: <Widget>[
          // Logout button in the app bar
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
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
      body: Column(
        children: [
          SizedBox(height: screenSize.height * 0.02),
          // Search bar for filtering users
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterUsers(query);
              },
              decoration: InputDecoration(
                labelText: 'Search Users',
                hintText: 'Search with Name or Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Display user list
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(filteredData[index]['name'].toString()),
                            subtitle: Text(
                                filteredData[index]['mobile_no'].toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Delete button for each user
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    deleteItem({
                                      'id': filteredData[index]['id'],
                                      'mobile_no': filteredData[index]
                                          ['mobile_no'],
                                    }, context);
                                  },
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ],
      ),
      // Floating Action Button for adding a new user
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            mini: true,
            onPressed: () async {
              // Navigate to the AdminRegister screen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminRegister(role: widget.role),
                ),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add',
          ),
          SizedBox(height: 6),
          Text(
            'Add',
            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
