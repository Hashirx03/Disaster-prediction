import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'cyclone.dart';
import 'earthquake.dart';
import 'floodprediction.dart';
import 'governancehome.dart';
import 'landslide.dart';
import 'main.dart';
import 'manage_users.dart';
import 'notification.dart';
import 'predictionview.dart';

class AdminDisasterInfoPage extends StatefulWidget {
  @override
  _AdminDisasterInfoPageState createState() => _AdminDisasterInfoPageState();
}

class _AdminDisasterInfoPageState extends State<AdminDisasterInfoPage> {
  String? username;
  Map<String, dynamic>? userProfile;
  String? disasterType;
  String description = '';
  String affectedLocation = '';
  
  final List<String> disasterTypes = [
    'Cyclone',
    'Earthquake',
    'Flood',
    'Landslide',
  ];

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
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

  Future<void> _submitDisasterAlert() async {
    if (disasterType != null && description.isNotEmpty && affectedLocation.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.225.190:8000/share_alert'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'disaster_type': disasterType,
            'affected_location': affectedLocation,
            'description': description,
          }),
        );

        if (response.statusCode == 201) {
          // Show a success message or navigate to another page if needed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert shared successfully')));
        } else {
          // Handle error response from backend
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share alert')));
        }
      } catch (e) {
        // Handle network or other errors
        print('Error submitting disaster alert: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred while submitting alert')));
      }
    } else {
      // Show a reminder message to fill in all fields
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  void _onDrawerItemTap(String item) {
    Navigator.pop(context); // Close the drawer
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
          MaterialPageRoute(builder: (context) => const LandslidePredictionPage()),
        );
        break;
      case 'Earth Quake Detector':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EarthquakePredictionPage()),
        );
        break;
      case 'Cyclone Detector':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CyclonePredictionPage()),
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
      case 'alert':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDisasterInfoPage()),
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
                MaterialPageRoute(builder: (context) => const NotificationPage()),
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
    // Background Image
    Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bgg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    ),
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center( // Center the content
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Ensure content is centered
            children: [
              const SizedBox(height: 16),
              // Dropdown for disaster type selection
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: DropdownButton<String>(
                  value: disasterType,
                  hint: const Text('Select Disaster Type'),
                  onChanged: (String? newValue) {
                    setState(() {
                      disasterType = newValue;
                    });
                  },
                  items: disasterTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(value, style: TextStyle(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Text field for affected location
              TextField(
                onChanged: (value) {
                  setState(() {
                    affectedLocation = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Affected Location',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Text field for description with a little height
              TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                maxLines: 3, // Control the height of the description field
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Submit button with improved styling
              ElevatedButton(
                onPressed: _submitDisasterAlert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text(
                  'Share Alert',
                  style: TextStyle(
                    fontSize: 18, // Larger text size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
)


    );
  }
}
