import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import 'officer_home_page.dart'; 
import 'package:my_app/officer_home_page.dart';
// Import the Officer Home Page
import 'officer_home_page.dart'; // Import the Officer Home Page


class OfficerLoginPage extends StatelessWidget {
  final Client client;

  OfficerLoginPage({required this.client});

  final TextEditingController _officerIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _officerLogin(BuildContext context) async {
  final officerId = _officerIdController.text.trim();
  final password = _passwordController.text.trim();
  final databases = Databases(client);

  try {
    print('Query Sent: officer_id = $officerId');

    // Debug: Print all documents in the collection
    final allDocuments = await databases.listDocuments(
      databaseId: '67c34dcb001fb8f9397d',
      collectionId: '67c411b30000be22f0d9',
    );
    print("All Documents: ${allDocuments.documents.map((doc) => doc.data).toList()}");

    final response = await databases.listDocuments(
      databaseId: '67c34dcb001fb8f9397d',
      collectionId: '67c411b30000be22f0d9',
      queries: [
        Query.equal('officer_id', officerId), // Ensure field name matches Appwrite
      ],
    );

    print('Response Documents: ${response.documents}');

    if (response.documents.isNotEmpty) {
      final document = response.documents.first;
      print("Document Data: ${document.data}");

      final storedPassword = document.data['password'];

      if (storedPassword == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OfficerHomePage(client: client),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Officer ID')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Officer login failed: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png', // Add your logo in the assets folder
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              // Officer ID Field
              TextField(
                controller: _officerIdController,
                decoration: InputDecoration(
                  labelText: 'Officer ID',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Officer Login Button
              ElevatedButton(
                onPressed: () => _officerLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Officer Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // Back to Regular Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the regular login page
                },
                child: Text(
                  'Not an officer? Regular Login',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
