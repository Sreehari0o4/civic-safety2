import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'home_page.dart'; // Import the Home Page
import 'sign_up_page.dart'; // Import the Sign Up Page
import 'officer_login_page.dart'; // Import the Officer Login Page

class SignInPage extends StatelessWidget {
  final Client client;

  SignInPage({required this.client});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final account = Account(client);

    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(client: client)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
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
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
              // Sign In Button
              ElevatedButton(
                onPressed: () => _signIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // Sign Up Link
              TextButton(
                onPressed: () {
                  // Navigate to the Sign Up Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(client: client),
                    ),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Are you an officer? Link
              TextButton(
                onPressed: () {
                  // Navigate to the Officer Login Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfficerLoginPage(client: client),
                    ),
                  );
                },
                child: Text(
                  'Are you an officer? Login',
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