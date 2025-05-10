// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ManageUsersPage extends StatefulWidget {
//   @override
//   _ManageUsersPageState createState() => _ManageUsersPageState();
// }

// class _ManageUsersPageState extends State<ManageUsersPage> {
//   late Future<List<Map<String, dynamic>>> _users;

//   // Fetch users from the Flask API
//   Future<List<Map<String, dynamic>>> fetchUsers() async {
//     final response = await http.get(Uri.parse('http://192.168.50.190:8000/users'));

//     if (response.statusCode == 200) {
//       List<dynamic> usersJson = json.decode(response.body);
//       return usersJson.map((user) => user as Map<String, dynamic>).toList();
//     } else {
//       throw Exception('Failed to load users');
//     }
//   }

//   // Delete user from the Flask API
//   void _deleteUser(int userId) async {
//     final response = await http.delete(
//       Uri.parse('http://192.168.50.190:8000/users/$userId'),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         _users = fetchUsers();
//       });
//     } else {
//       throw Exception('Failed to delete user');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _users = fetchUsers();  // Load users on page load
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Users'),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _users,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No users found.'));
//           }

//           // Data from the database
//           List<Map<String, dynamic>> users = snapshot.data!;

//           // Display users in a ListView with delete button
//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               var user = users[index];
//               return Card(
//                 elevation: 4.0,
//                 margin: EdgeInsets.symmetric(vertical: 8.0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Full Name: ${user['full_name']}', style: TextStyle(fontSize: 16)),
//                           Text('Role: ${user['role']}', style: TextStyle(fontSize: 16)),
//                           Text('Email: ${user['email']}', style: TextStyle(fontSize: 16)),
//                           Text('Username: ${user['username']}', style: TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           _deleteUser(user['id']);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late Future<List<Map<String, dynamic>>> _users;

  // Fetch users from the Flask API
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://192.168.50.190:8000/users'));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Delete user from the Flask API
  void _deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.50.190:8000/users/$userId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _users = fetchUsers();
      });
    } else {
      throw Exception('Failed to delete user');
    }
  }

  @override
  void initState() {
    super.initState();
    _users = fetchUsers(); // Load users on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bgg.jpg', // Use the same image path as in UserHomePage
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.blue.withOpacity(0.5),
          ),
          // Main content
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _users,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No users found.'));
              }

              // Data from the database
              List<Map<String, dynamic>> users = snapshot.data!;

              // Display users in a ListView with delete button
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Full Name: ${user['full_name']}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Role: ${user['role']}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Email: ${user['email']}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Username: ${user['username']}',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteUser(user['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
