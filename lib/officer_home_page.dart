import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

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
        child: Text(
          'Welcome, Officer!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}