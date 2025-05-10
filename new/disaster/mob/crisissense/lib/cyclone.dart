import 'package:crisissense/earthquake.dart';
import 'package:crisissense/floodprediction.dart';
import 'package:crisissense/governancehome.dart';
import 'package:crisissense/landslide.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'manage_users.dart';
import 'notification.dart';
import 'predictionview.dart';

class CyclonePredictionPage extends StatefulWidget {
  const CyclonePredictionPage({super.key});

  @override
  _CyclonePredictionPageState createState() => _CyclonePredictionPageState();
}

class _CyclonePredictionPageState extends State<CyclonePredictionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController maxWindController = TextEditingController();
  final TextEditingController lowWindNEController = TextEditingController();
  final TextEditingController lowWindSEController = TextEditingController();
  final TextEditingController lowWindSWController = TextEditingController();
  final TextEditingController lowWindNWController = TextEditingController();
  final TextEditingController moderateWindNEController =
      TextEditingController();
  final TextEditingController moderateWindSEController =
      TextEditingController();
  final TextEditingController moderateWindNWController =
      TextEditingController();
  String? username;
  String? email;
  String? role;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    if (username != null) {
      await _fetchUserProfile(username!);
    }
  }

  Future<void> _fetchUserProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.50.190:8000/profile?username=$username'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // URL of your Flask backend
  final String apiUrl = 'http://192.168.50.190:8000/predictc';

  Future<void> _predictCycloneRisk() async {
    if (_formKey.currentState!.validate()) {
      // Gather and parse inputs as double
      final requestData = {
        "latitude": double.tryParse(latitudeController.text),
        "longitude": double.tryParse(longitudeController.text),
        "maximum_wind": double.tryParse(maxWindController.text),
        "low_wind_ne": double.tryParse(lowWindNEController.text),
        "low_wind_se": double.tryParse(lowWindSEController.text),
        "low_wind_sw": double.tryParse(lowWindSWController.text),
        "low_wind_nw": double.tryParse(lowWindNWController.text),
        "moderate_wind_ne": double.tryParse(moderateWindNEController.text),
        "moderate_wind_se": double.tryParse(moderateWindSEController.text),
        "moderate_wind_nw": double.tryParse(moderateWindNWController.text),
      };

      // Check if any input is null (invalid double conversion)
      if (requestData.values.contains(null)) {
        _showErrorDialog('Please enter valid numbers for all fields.');
        return;
      }

      try {
        // Send POST request to the backend
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        // Handle response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          // Extract the prediction class from the response
          final prediction = responseData['prediction'];

          // Show the prediction in the dialog
          _showPredictionDialog('Prediction: $prediction');
        } else {
          _showErrorDialog('Failed to get prediction');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showPredictionDialog(String prediction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cyclone Prediction Result'),
          content: Text('Cyclone Probability: $prediction'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onDrawerItemTap(String item) {
    Navigator.pop(context); // Close the drawer
    // Handle navigation based on the item clicked
    switch (item) {
      case 'Home':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GovernanceHomePage()),
        );
        break;
      case 'Land Slide Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LandslidePredictionPage()),
        );
        break;
      case 'Earth Quake Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EarthquakePredictionPage()),
        );
        break;
      case 'Cyclone Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CyclonePredictionPage()),
        );
        break;
      case 'Flood Detector':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FloodPredictionPage()),
        );
        break;

      case 'User History':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PredictionHistoryPage()),
        );
        break;
      case 'Manage users':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageUsersPage()),
        );
        break;

      case 'Sign Out':
        SharedPreferences.getInstance().then((prefs) {
          prefs.clear();
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
        break;
      default:
        break;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Crisis Sense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              padding:
                  const EdgeInsets.only(top: 5), // Top padding for "Menu" text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (userProfile != null)
                    SizedBox(
                      height: 110, // Restrict the card's height
                      child: Center(
                        // Center the card horizontally
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${userProfile!['full_name']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Username: ${userProfile!['username']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Role: ${userProfile!['role']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Email: ${userProfile!['email']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Center(
                        child:
                            CircularProgressIndicator()), // Show loading indicator while fetching
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _onDrawerItemTap('Home'),
            ),
            ListTile(
              leading: const Icon(Icons.landslide),
              title: const Text('Land Slide Detector'),
              onTap: () => _onDrawerItemTap('Land Slide Detector'),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Earth Quake Detector'),
              onTap: () => _onDrawerItemTap('Earth Quake Detector'),
            ),
            ListTile(
              leading: const Icon(Icons.waves),
              title: const Text('Cyclone Detector'),
              onTap: () => _onDrawerItemTap('Cyclone Detector'),
            ),
            ListTile(
              leading: const Icon(Icons.water),
              title: const Text('Flood Detector'),
              onTap: () => _onDrawerItemTap('Flood Detector'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Manage users'),
              onTap: () => _onDrawerItemTap('Manage users'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('User History'),
              onTap: () => _onDrawerItemTap('User History'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _onDrawerItemTap('Sign Out'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bgg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 8,
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Enter Parameters for Cyclone Prediction',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(latitudeController, 'Latitude'),
                          _buildInputField(longitudeController, 'Longitude'),
                          _buildInputField(maxWindController, 'Maximum Wind'),
                          _buildInputField(lowWindNEController, 'Low Wind NE'),
                          _buildInputField(lowWindSEController, 'Low Wind SE'),
                          _buildInputField(lowWindSWController, 'Low Wind SW'),
                          _buildInputField(lowWindNWController, 'Low Wind NW'),
                          _buildInputField(
                              moderateWindNEController, 'Moderate Wind NE'),
                          _buildInputField(
                              moderateWindSEController, 'Moderate Wind SE'),
                          _buildInputField(
                              moderateWindNWController, 'Moderate Wind NW'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: _predictCycloneRisk,
                            child: const Text('Predict'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelStyle: const TextStyle(color: Colors.blueAccent),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    maxWindController.dispose();
    lowWindNEController.dispose();
    lowWindSEController.dispose();
    lowWindSWController.dispose();
    lowWindNWController.dispose();
    moderateWindNEController.dispose();
    moderateWindSEController.dispose();
    moderateWindNWController.dispose();
    super.dispose();
  }
}
