import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'notification.dart'; // Import your NotificationPage class

class PredictionHistoryPage extends StatefulWidget {
  @override
  _PredictionHistoryPageState createState() => _PredictionHistoryPageState();
}

class _PredictionHistoryPageState extends State<PredictionHistoryPage> {
  late Future<List<Map<String, dynamic>>> _predictions;

  @override
  void initState() {
    super.initState();
    _predictions = DatabaseHelper.instance.fetchAllPredictions(); // Fetch all predictions on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back), 
              onPressed: () {
                Navigator.pop(context); 
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgg.jpg'), // Ensure the image is in the 'assets' folder
            fit: BoxFit.cover, // This will ensure the image covers the entire screen
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _predictions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No predictions found.'));
            }

            // Data from the database
            List<Map<String, dynamic>> predictions = snapshot.data!;

            // Display data in a Card with a black background and white bold text
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  var prediction = predictions[index];
                  return Card(
                    color: Colors.black,
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username: ${prediction['username'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Prediction Type: ${prediction['prediction_type'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Result: ${prediction['result'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Date Time: ${prediction['date_time'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
