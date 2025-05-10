import 'dart:convert';
import 'package:crisissense/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cyclone_u.dart';
import 'earthquake_u.dart';
import 'floodprediction_u.dart';
import 'show_alerts.dart';
import 'userhome.dart';
import 'landslide_u.dart'; // Import shared_preferences

class EmergencyRequestPage extends StatefulWidget {
  const EmergencyRequestPage({Key? key}) : super(key: key);

  @override
  _EmergencyRequestPageState createState() => _EmergencyRequestPageState();
}

class _EmergencyRequestPageState extends State<EmergencyRequestPage> {
  String? disasterType;
  String? helpType;
  TextEditingController descriptionController = TextEditingController();
  double? latitude;
  double? longitude;
  String? username; // Variable to store username
  final List<String> disasterTypes = [
    'Earthquake',
    'Flood',
    'Landslide',
    'Cyclone',
  ];
  final List<String> helpTypes = ['Rescue', 'Medical', 'Food', 'Shelter'];

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

  // To get the current location of the user
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  // Function to save the request data to the backend API
  Future<void> _saveRequest() async {
    final response = await http.post(
      Uri.parse('http://192.168.225.190:8000/emergency'),
      body: {
        'username': username!, // Include username in the request
        'disaster_type': disasterType!,
        'help_type': helpType!,
        'description': descriptionController.text,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    if (response.statusCode == 200) {
      print('Request saved and email sent');
    } else {
      print('Failed to save request');
    }
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (disasterType == null || helpType == null || descriptionController.text.isEmpty || latitude == null || longitude == null) {
      // Notify the user to fill all fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and get location!')),
      );
    } else {
      await _saveRequest();
      // You can show a success message or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergency request sent successfully!')),
      );
    }
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
          MaterialPageRoute(builder: (context) => const FloodPredictionPage_U()),
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
                MaterialPageRoute(
                    builder: (context) => AlertsPage()),
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
            padding: const EdgeInsets.only(top: 5), // Top padding for "Menu" text
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
                    child: Center( // Center the card horizontally
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
                  const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching
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
          // Background image positioned below the app bar and filling the screen
          Positioned.fill(
            child: Image.asset(
              'assets/bgg.jpg',
              fit: BoxFit.cover, // Ensures the image covers the screen
            ),
          ),
          Center(
            // This centers the Card in the middle of the screen
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // To prevent overflow when keyboard is visible
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Request',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: disasterType,
                          decoration: InputDecoration(
                            labelText: 'Disaster Type',
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: disasterTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              disasterType = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: helpType,
                          decoration: InputDecoration(
                            labelText: 'Help Type',
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: helpTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              helpType = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          child: const Text('Get Current Location'),
                        ),
                        if (latitude != null && longitude != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Latitude: $latitude, Longitude: $longitude',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Submit Request'),
                          ),
                        ),
                      ],
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
}
