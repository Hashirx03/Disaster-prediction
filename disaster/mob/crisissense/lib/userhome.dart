import 'dart:convert';
import 'package:crisissense/show_alerts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landslide_u.dart';
import 'floodprediction_u.dart';
import 'earthquake_u.dart';
import 'cyclone_u.dart';
import 'main.dart';
import 'requesthelp.dart';
import 'package:http/http.dart' as http;

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String? username;
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

  // Function to handle navigation drawer item clicks
  void _onDrawerItemTap(String item) {
    Navigator.pop(context); // Close the drawer
    // Handle navigation based on the item clicked
    switch (item) {
       case 'Home':
         Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserHomePage()),
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
        Navigator.pushReplacement(
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
          Positioned.fill(
            child: Image.asset(
              'assets/bgg.jpg', // Update with your image path
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.blue.withOpacity(0.5),
          ),
          Column(
            children: [
              const SizedBox(height: 130),
              Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username != null ? 'Welcome, $username!' : 'Welcome!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'As a user, you can access crisis predictions and request emergency help.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
