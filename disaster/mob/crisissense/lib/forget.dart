import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isUsernameVerified = false;
  String verificationMessage = '';

  // Function to verify if the username exists
  Future<void> verifyUsername(String username) async {
    final response = await http.get(Uri.parse('http://192.168.225.190:8000/verify-username?username=$username'));

    if (response.statusCode == 200) {
      setState(() {
        isUsernameVerified = true;
        verificationMessage = 'Username found! Please set a new password.';
      });
    } else {
      setState(() {
        verificationMessage = 'Username not found. Please try again.';
        isUsernameVerified = false;
      });
    }
  }

  // Function to update the password
  Future<void> updatePassword(String username, String newPassword) async {
    final response = await http.post(
      Uri.parse('http://192.168.225.190:8000/update-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'new_password': newPassword,
        'confirm_password': newPassword
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crisis Sense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity, // Ensures the container spans the entire screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgg.jpg'), // Add your image asset
            fit: BoxFit.cover, // Ensures the image covers the screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0), // Small gap from top margin
          child: SingleChildScrollView(  // Make it scrollable in case of smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.center,  // Center content horizontally
              children: [
                // Wrap the form inside a Card widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 8,  // Adds shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),  // Round the corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Username field with styling
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Verify button with styling
                          ElevatedButton(
                            onPressed: () {
                              if (usernameController.text.isNotEmpty) {
                                verifyUsername(usernameController.text);
                              }
                            },
                            child: Text('Verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Display the verification message
                          Text(
                            verificationMessage,
                            style: TextStyle(
                              color: isUsernameVerified ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Show password fields only if username is verified
                          if (isUsernameVerified) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: newPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  labelStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Update button with styling
                            ElevatedButton(
                              onPressed: () {
                                if (newPasswordController.text == confirmPasswordController.text) {
                                  updatePassword(usernameController.text, newPasswordController.text);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Passwords do not match.')),
                                  );
                                }
                              },
                              child: Text('Update Password'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
