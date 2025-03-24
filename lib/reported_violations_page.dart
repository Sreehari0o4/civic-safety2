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

  // Fetch only "submitted" violations
  Future<void> fetchViolations() async {
    try {
      final response = await databases.listDocuments(
        databaseId: '67c34dcb001fb8f9397d', // Your Appwrite Database ID
        collectionId: '67c34dea000d11566fcc', // Your Collection ID
      );

      setState(() {
        violations = response.documents
            .where((doc) => doc.data['status'] == 'submitted')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching violations: $e');
      setState(() {
        isLoading = false;
      });
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
