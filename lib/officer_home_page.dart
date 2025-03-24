import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
<<<<<<< HEAD
import 'reported_violations_page.dart'; // Ensure this file exists
=======
>>>>>>> 9081d97db00ea7a320a7948d7f50ac0702b4900b

class OfficerHomePage extends StatelessWidget {
  final Client client;

  OfficerHomePage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Officer Home'),
      ),
      body: Center(
<<<<<<< HEAD
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, Officer!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Reported Violations Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportedViolationsPage(client: client),
                  ),
                );
              },
              child: Text('View Violations'),
            ),
          ],
=======
        child: Text(
          'Welcome, Officer!',
          style: TextStyle(fontSize: 24),
>>>>>>> 9081d97db00ea7a320a7948d7f50ac0702b4900b
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 9081d97db00ea7a320a7948d7f50ac0702b4900b
