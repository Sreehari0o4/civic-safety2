import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'officer_login_page.dart';

class SignInPage extends StatefulWidget {
  final Client client;

  SignInPage({required this.client});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final account = Account(widget.client);
    final databases = Databases(widget.client);

    setState(() {
      _isLoading = true;
    });

    try {
      // Create session (Login)
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Get user details to check if blocked
      final userId = session.userId;
      final userDoc = await databases.getDocument(
        databaseId: '67c34dcb001fb8f9397d', // Your database ID
        collectionId: '67e808ac003001212055', // Users collection ID
        documentId: userId,
      );

      if (userDoc.data['blocked'] == true) {
        // User is blocked, log them out and show message
        await account.deleteSession(sessionId: 'current');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your account has been blocked. Contact support.')),
        );
      } else {
        // User is not blocked, navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(client: widget.client)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                'assets/logo.png',
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
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _signIn(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text('Sign In', style: TextStyle(fontSize: 16)),
                    ),
              SizedBox(height: 20),

              // Sign Up Link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage(client: widget.client)),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),

              // Officer Login Link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OfficerLoginPage(client: widget.client)),
                  );
                },
                child: Text(
                  'Are you an officer? Login',
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
