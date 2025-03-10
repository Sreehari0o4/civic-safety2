import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
// Import the Home Page
import 'sign_in_page.dart'; // Import the Sign In Page

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize Appwrite client
  final Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
    .setProject('67c345160023bc7bcb88'); // Your Appwrite project ID

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(client: client),
      debugShowCheckedModeBanner: false, // Set SignInPage as the home
    );
  }
}