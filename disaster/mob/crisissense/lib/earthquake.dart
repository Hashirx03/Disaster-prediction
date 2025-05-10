import 'package:crisissense/governancehome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cyclone.dart';
import 'landslide.dart';
import 'floodprediction.dart';
import 'main.dart';
import 'manage_users.dart';
import 'notification.dart';
import 'predictionview.dart';


class EarthquakePredictionPage extends StatefulWidget {
  const EarthquakePredictionPage({super.key});

  @override
  _EarthquakePredictionPageState createState() =>
      _EarthquakePredictionPageState();
}

class _EarthquakePredictionPageState extends State<EarthquakePredictionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cdiController = TextEditingController();
  final TextEditingController mmiController = TextEditingController();
  final TextEditingController alertController = TextEditingController();
  final TextEditingController tsunamiController = TextEditingController();
  final TextEditingController sigController = TextEditingController();
  final TextEditingController netController = TextEditingController();
  final TextEditingController dminController = TextEditingController();
  final TextEditingController gapController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
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
        Uri.parse('http://192.168.225.190:8000/profile?username=$username'),
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

  final String apiUrl = 'http://192.168.225.190:8000/predicte';

  Future<void> _predictEarthquakeRisk() async {
    if (_formKey.currentState!.validate()) {
      final requestData = {
        "cdi": double.tryParse(cdiController.text),
        "mmi": double.tryParse(mmiController.text),
        "alert": alertController.text,
        "tsunami": double.tryParse(tsunamiController.text),
        "sig": double.tryParse(sigController.text),
        "net": netController.text,
        "dmin": double.tryParse(dminController.text),
        "gap": double.tryParse(gapController.text),
        "depth": double.tryParse(depthController.text),
        "longitude": double.tryParse(longitudeController.text),
      };

      if (requestData.values.contains(null)) {
        _showErrorDialog('Please enter valid numbers for all fields.');
        return;
      }

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final prediction = responseData['prediction'];
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
          title: const Text('Earthquake Prediction Result'),
          content: Text('Earthquake Risk: $prediction'),
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
          MaterialPageRoute(
              builder: (context) => const GovernanceHomePage()),
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
                            'Enter Parameters for Earthquake Prediction',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(cdiController, 'CDI'),
                          _buildInputField(mmiController, 'MMI'),
                          _buildTextInputField(
                              alertController, 'Alert'), // Text field
                          _buildInputField(tsunamiController, 'Tsunami'),
                          _buildInputField(sigController, 'SIG'),
                          _buildTextInputField(
                              netController, 'Net'), // Text field
                          _buildInputField(dminController, 'Dmin'),
                          _buildInputField(gapController, 'Gap'),
                          _buildInputField(depthController, 'Depth'),
                          _buildInputField(longitudeController, 'Longitude'),
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
                            onPressed: _predictEarthquakeRisk,
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

  Widget _buildTextInputField(TextEditingController controller, String label) {
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
          return null;
        },
        keyboardType: TextInputType.text,
      ),
    );
  }

  @override
  void dispose() {
    cdiController.dispose();
    mmiController.dispose();
    alertController.dispose();
    tsunamiController.dispose();
    sigController.dispose();
    netController.dispose();
    dminController.dispose();
    gapController.dispose();
    depthController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}
