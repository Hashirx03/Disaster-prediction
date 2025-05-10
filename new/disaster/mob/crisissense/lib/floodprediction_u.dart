import 'package:crisissense/cyclone_u.dart';
import 'package:crisissense/earthquake_u.dart';
import 'package:crisissense/userhome.dart';
import 'package:crisissense/landslide_u.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'main.dart';
import 'requesthelp.dart';
import 'show_alerts.dart';

class FloodPredictionPage_U extends StatefulWidget {
  const FloodPredictionPage_U({super.key});

  @override
  _FloodPredictionPageState createState() => _FloodPredictionPageState();
}

class _FloodPredictionPageState extends State<FloodPredictionPage_U> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController monsoonIntensityController =
      TextEditingController();
  final TextEditingController topographyDrainageController =
      TextEditingController();
  final TextEditingController riverManagementController =
      TextEditingController();
  final TextEditingController damsQualityController = TextEditingController();
  final TextEditingController siltationController = TextEditingController();
  final TextEditingController disasterPreparednessController =
      TextEditingController();
  final TextEditingController watershedsController = TextEditingController();
  final TextEditingController infrastructureController =
      TextEditingController();
  final TextEditingController populationScoreController =
      TextEditingController();
  final TextEditingController politicalFactorsController =
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
 final String apiUrl = 'http://192.168.50.190:8000/predictf';

 Future<void> _predictFloodRisk() async {
  if (_formKey.currentState!.validate()) {
    // Convert inputs to double before sending
    final requestData = {
      "monsoon_intensity": double.tryParse(monsoonIntensityController.text) ?? 0.0,
      "topography_drainage": double.tryParse(topographyDrainageController.text) ?? 0.0,
      "river_management": double.tryParse(riverManagementController.text) ?? 0.0,
      "dams_quality": double.tryParse(damsQualityController.text) ?? 0.0,
      "siltation": double.tryParse(siltationController.text) ?? 0.0,
      "disaster_preparedness": double.tryParse(disasterPreparednessController.text) ?? 0.0,
      "watersheds": double.tryParse(watershedsController.text) ?? 0.0,
      "infrastructure": double.tryParse(infrastructureController.text) ?? 0.0,
      "population_score": double.tryParse(populationScoreController.text) ?? 0.0,
      "political_factors": double.tryParse(politicalFactorsController.text) ?? 0.0,
    };

    // Check for invalid numbers
    if (requestData.values.contains(0.0) && requestData.values.length > 0) {
      _showErrorDialog('Please enter valid numbers for all fields.');
      return;
    }

    // Send POST request to the backend
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    // Handle response
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final prediction = responseData['flood_probability'];

      // Print raw prediction value in logs
      print("Raw Prediction Value: $prediction");

      // Show result with classification and color
      _showPredictionDialog(prediction);
    } else {
      _showErrorDialog('Failed to get prediction. Error code: ${response.statusCode}');
    }
  }
}


  void _showPredictionDialog(double prediction) {
  String riskLevel;
  Color riskColor;

  if (prediction < 0.5) {
    riskLevel = "Low Risk";
    riskColor = Colors.green;
  } else {
    riskLevel = "High Risk";
    riskColor = Colors.red;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Flood Prediction Result', style: TextStyle(color: riskColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Flood Probability: ${prediction.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              riskLevel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: riskColor),
            ),
          ],
        ),
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
                            'Enter Parameters for Flood Prediction',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                              monsoonIntensityController, 'Monsoon Intensity'),
                          _buildInputField(topographyDrainageController,
                              'Topography Drainage'),
                          _buildInputField(
                              riverManagementController, 'River Management'),
                          _buildInputField(
                              damsQualityController, 'Dams Quality'),
                          _buildInputField(siltationController, 'Siltation'),
                          _buildInputField(disasterPreparednessController,
                              'Ineffective Disaster Preparedness'),
                          _buildInputField(watershedsController, 'Watersheds'),
                          _buildInputField(infrastructureController,
                              'Deteriorating Infrastructure'),
                          _buildInputField(
                              populationScoreController, 'Population Score'),
                          _buildInputField(
                              politicalFactorsController, 'Political Factors'),
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
                            onPressed: _predictFloodRisk,
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
    monsoonIntensityController.dispose();
    topographyDrainageController.dispose();
    riverManagementController.dispose();
    damsQualityController.dispose();
    siltationController.dispose();
    disasterPreparednessController.dispose();
    watershedsController.dispose();
    infrastructureController.dispose();
    populationScoreController.dispose();
    politicalFactorsController.dispose();
    super.dispose();
  }
}
