import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'report_violation_page.dart';
import 'report_status_page.dart';
import 'rewards_page.dart';
import 'sign_in_page.dart'; // Assuming you have a SignInPage

class HomePage extends StatefulWidget {
  final Client client;

  HomePage({required this.client});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'Username'; // Default username
  String userId = ''; // Store user ID
  bool isLoading = true; // To show loading state

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final account = Account(widget.client);
      final user = await account.get();
      setState(() {
        username = user.name; // Assuming the user's name is stored in the 'name' field
        userId = user.$id; // Store the user ID
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final account = Account(widget.client);
      await account.deleteSession(sessionId: 'current'); // Logout the current session
      // Navigate to the Sign In Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(client: widget.client),
        ),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Set bottom navigation bar color to black
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          if (index == 3) {
            _logout(); // Logout when the last item is tapped
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting section with animation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      isLoading
                          ? CircularProgressIndicator() // Show loading indicator
                          : Text(
                              username,
                              style: TextStyle(
                                fontSize: 20, // Increased font size
                                fontWeight: FontWeight.bold, // Optional: Make it bold
                                color: Colors.grey[700], // Lighter shade of black
                              ),
                            ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 28, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Buttons Section with animation and hover effect
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportViolationPage(client: widget.client),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'REPORT VIOLATION',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportStatusPage(client: widget.client),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'HISTORY',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RewardsPage(
                                    client: widget.client,
                                    userId: userId, // Pass userId correctly
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'REWARD',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
