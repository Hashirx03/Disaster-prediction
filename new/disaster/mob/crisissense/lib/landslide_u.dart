import 'package:crisissense/cyclone_u.dart';
import 'package:crisissense/earthquake_u.dart';
import 'package:crisissense/floodprediction_u.dart';
import 'package:crisissense/userhome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'main.dart';
import 'requesthelp.dart';
import 'show_alerts.dart';

class LandslidePredictionPage_U extends StatefulWidget {
  const LandslidePredictionPage_U({super.key});

  @override
  _LandslidePredictionState createState() => _LandslidePredictionState();
}

class _LandslidePredictionState extends State<LandslidePredictionPage_U> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController CurvatureController = TextEditingController();
  final TextEditingController EarthquakeController = TextEditingController();
  final TextEditingController ElevationController = TextEditingController();
  final TextEditingController FlowController = TextEditingController();
  final TextEditingController LithologyController = TextEditingController();
  final TextEditingController NDVIController = TextEditingController();
  final TextEditingController NDWIController = TextEditingController();
  final TextEditingController PrecipitationController = TextEditingController();
  final TextEditingController ProfileController = TextEditingController();
  final TextEditingController SlopeController = TextEditingController();
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
  final String apiUrl = 'http://192.168.50.190:8000/predictl';

  Future<void> _predictLandslideRisk() async {
  print('Starting _predictLandslideRisk() function');

  if (_formKey.currentState!.validate()) {
    print('Form validation passed');

    // Gather and parse inputs as double
    final requestData = {
      "Curvature": double.tryParse(CurvatureController.text),
      "Earthquake": double.tryParse(EarthquakeController.text),
      "Elevation": double.tryParse(ElevationController.text),
      "Flow": double.tryParse(FlowController.text),
      "Lithology": double.tryParse(LithologyController.text),
      "NDVI": double.tryParse(NDVIController.text),
      "NDWI": double.tryParse(NDWIController.text),
      "Precipitation": double.tryParse(PrecipitationController.text),
      "Profile": double.tryParse(ProfileController.text),
      "Slope": double.tryParse(SlopeController.text),
    };

    print('Parsed input values: $requestData');

    // Check if any input is null (invalid double conversion)
    if (requestData.values.contains(null)) {
      print('Invalid input detected: $requestData');
      _showErrorDialog('Please enter valid numbers for all fields.');
      return;
    }

    try {
      print('Sending POST request to: $apiUrl');
      print('Request data: ${json.encode(requestData)}');

      // Send POST request to the backend
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Received response with status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Decoded response data: $responseData');

        final prediction = responseData['landslide_probability'];
        print('Extracted prediction: $prediction');

        if (username != null) {
          print('Saving prediction to database for user: $username');
          await DatabaseHelper.instance.insertPrediction(
              username!, 'Landslide Prediction', prediction.toString());

        }

        // Map the prediction to a message
        String message;
        if (prediction == 1) {
          message = 'Landslide detected.';
        } else if (prediction == 0) {
          message = 'No landslide detected.';
        } else {
          message = 'Unexpected prediction value: $prediction';
        }

        print('Final prediction message: $message');
        _showPredictionDialog(message);
      } else {
        print('Error: Failed to get prediction. Response body: ${response.body}');
        _showErrorDialog('Failed to get prediction');
      }
    } catch (e) {
      print('Exception caught: $e');
      _showErrorDialog('An error occurred: $e');
    }
  } else {
    print('Form validation failed');
  }

  print('Exiting _predictLandslideRisk() function');
}


  void _showPredictionDialog(String prediction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Landslide Prediction Result'),
          content: Text('Result: $prediction'),
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

  void _onDrawerItemTap(String item) {
    Navigator.pop(context); // Close the drawer
    // Handle navigation based on the item clicked
    switch (item) {
      case 'Home':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
        break;
      case 'Profile':
        // Navigate to Profile
        break;
      case 'Land Slide Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LandslidePredictionPage_U()),
        );
        break;
      case 'Earth Quake Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EarthquakePredictionPage_U()),
        );
        break;
      case 'Cyclone Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CyclonePredictionPage_U()),
        );
        break;
      case 'Flood Detector':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const FloodPredictionPage_U()),
        );
        break;
      case 'Emergency Help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyRequestPage()),
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
                MaterialPageRoute(builder: (context) => AlertsPage()),
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
              leading: const Icon(Icons.help),
              title: const Text('Emergency Help'),
              onTap: () => _onDrawerItemTap('Emergency Help'),
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
                            'Enter Parameters for Landslide Prediction',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(CurvatureController, 'Curvature'),
                          _buildInputField(EarthquakeController, 'Earthquake'),
                          _buildInputField(ElevationController, 'Elevation'),
                          _buildInputField(FlowController, 'Flow'),
                          _buildInputField(LithologyController, 'Lithology'),
                          _buildInputField(NDVIController, 'NDVI'),
                          _buildInputField(NDWIController, 'NDWI'),
                          _buildInputField(
                              PrecipitationController, 'Precipitation'),
                          _buildInputField(ProfileController, 'Profile'),
                          _buildInputField(SlopeController, 'Slope'),
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
                            onPressed: _predictLandslideRisk,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
