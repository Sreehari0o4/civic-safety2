import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'reported_violations_page.dart';
import 'blocked_users_page.dart'; // Ensure this file exists

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, Officer!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),

            // View Violations Button
            _buildAnimatedButton(
              context,
              text: 'View Violations',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportedViolationsPage(client: client),
                  ),
                );
              },
            ),

            SizedBox(height: 15),

            // Blocked Users Button
            _buildAnimatedButton(
              context,
              text: 'Blocked Users',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedUsersPage(client: client),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return MouseRegion(
      onEnter: (_) => {}, // Handles hover effect
      onExit: (_) => {},
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: 1.05),
        builder: (context, scale, child) {
          return AnimatedScale(
            scale: scale,
            duration: Duration(milliseconds: 150),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(text),
            ),
          );
        },
      ),
    );
  }
}
