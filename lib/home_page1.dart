import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'report_violation_page.dart'; // Import the Report Violation Page
import 'report_status_page.dart'; // Import the Report Status Page
import 'rewards_page.dart'; // Import the Rewards Page

class HomePage extends StatelessWidget {
  final Client client;

  HomePage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hello Section
            Card(
              child: ListTile(
                title: Text(
                  'Hello',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Welcome back!'),
              ),
            ),
            SizedBox(height: 20),
            // Report Section
            Card(
              child: ListTile(
                title: Text(
                  'Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Report a new violation'),
                trailing: Icon(Icons.report, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportViolationPage(client: client),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Violation History Section
            Card(
              child: ListTile(
                title: Text(
                  'Violation History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('View your reported violations'),
                trailing: Icon(Icons.history, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportStatusPage(client: client),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Reward Section
            Card(
              child: ListTile(
                title: Text(
                  'Reward',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('View your rewards'),
                trailing: Icon(Icons.monetization_on, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RewardsPage(client: client),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}