import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'violation_details_page.dart'; // Import the details page

class ReportedViolationsPage extends StatefulWidget {
  final Client client;

  ReportedViolationsPage({required this.client});

  @override
  _ReportedViolationsPageState createState() => _ReportedViolationsPageState();
}

class _ReportedViolationsPageState extends State<ReportedViolationsPage> {
  late Databases databases;
  List<Document> violations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    fetchViolations();
  }

  // Fetch only "submitted" violations from users who are NOT blocked
  Future<void> fetchViolations() async {
    try {
      final response = await databases.listDocuments(
        databaseId: '67c34dcb001fb8f9397d', // Your Appwrite Database ID
        collectionId: '67c34dea000d11566fcc', // Your Collection ID for violations
      );

      List<Document> filteredViolations = [];

      for (var doc in response.documents) {
        if (doc.data['status'] == 'submitted') {
          String userId = doc.data['user_id'] ?? '';
          if (await _isUserNotBlocked(userId)) {
            filteredViolations.add(doc);
          }
        }
      }

      setState(() {
        violations = filteredViolations;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching violations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check if the user is NOT blocked
  Future<bool> _isUserNotBlocked(String userId) async {
    if (userId.isEmpty) return false;

    try {
      final userDoc = await databases.getDocument(
        databaseId: '67c34dcb001fb8f9397d', // Your Appwrite Database ID
        collectionId: '67e808ac003001212055', // Your Collection ID for users
        documentId: userId,
      );
      return userDoc.data['blocked'] == false; // Ensure user is not blocked
    } catch (e) {
      print('Error fetching user data for ID $userId: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reported Violations')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : violations.isEmpty
              ? Center(child: Text("No submitted violations found."))
              : ListView.builder(
                  itemCount: violations.length,
                  itemBuilder: (context, index) {
                    final violation = violations[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text(
                          violation.data['violation_type'] ?? 'Unknown Violation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Location: ${violation.data['location'] ?? 'N/A'}\n"
                            "Date: ${violation.data['date'] ?? 'N/A'}"),
                        onTap: () {
                          // Navigate to details page on tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViolationDetailsPage(
                                client: widget.client,
                                violation: violation,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
