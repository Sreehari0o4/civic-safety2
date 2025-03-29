import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class ViolationDetailsPage extends StatefulWidget {
  final Client client;
  final Document violation;

  ViolationDetailsPage({required this.client, required this.violation});

  @override
  _ViolationDetailsPageState createState() => _ViolationDetailsPageState();
}

class _ViolationDetailsPageState extends State<ViolationDetailsPage> {
  late Databases databases;
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    _fetchUserDetails();
  }

  // Fetch user details from 'users' collection
  Future<void> _fetchUserDetails() async {
    String userId = widget.violation.data['user_id'] ?? '';
    if (userId.isNotEmpty) {
      try {
        final userDoc = await databases.getDocument(
          databaseId: '67c34dcb001fb8f9397d',
          collectionId: '67e808ac003001212055', // Users collection
          documentId: userId,
        );
        setState(() {
          userDetails = userDoc.data;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching user details: $e");
        setState(() => isLoading = false);
      }
    }
  }

  // Approve Violation with Fine
  Future<void> approveViolation(String documentId) async {
    TextEditingController fineController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Fine Amount'),
          content: TextField(
            controller: fineController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter fine amount"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (fineController.text.isNotEmpty) {
                  try {
                    double fineAmount = double.tryParse(fineController.text) ?? 0.0;
                    await databases.updateDocument(
                      databaseId: '67c34dcb001fb8f9397d',
                      collectionId: '67c34dea000d11566fcc',
                      documentId: documentId,
                      data: {"status": "Approved", "amount": fineAmount},
                    );

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Violation Approved')));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error approving violation: $e');
                  }
                }
              },
              child: Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  // Reject Violation
  Future<void> rejectViolation(String documentId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reject Violation'),
          content: Text("Are you sure you want to reject this violation?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67c34dea000d11566fcc',
                    documentId: documentId,
                    data: {"status": "Rejected"},
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Violation Rejected')));
                  Navigator.pop(context);
                } catch (e) {
                  print('Error rejecting violation: $e');
                }
              },
              child: Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Block User and Cancel All Their Violations
  Future<void> blockUser(String userId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Block User"),
          content: Text("Are you sure you want to permanently block this user? All their submitted violations will be cancelled."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  // Step 1: Block the User
                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67e808ac003001212055', // Users collection
                    documentId: userId,
                    data: {"blocked": true},
                  );

                  // Step 2: Cancel all their submitted violations
                  final violationsResponse = await databases.listDocuments(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67c34dea000d11566fcc', // Violations collection
                    queries: [Query.equal("user_id", userId), Query.equal("status", "submitted")],
                  );

                  for (var violation in violationsResponse.documents) {
                    await databases.updateDocument(
                      databaseId: '67c34dcb001fb8f9397d',
                      collectionId: '67c34dea000d11566fcc',
                      documentId: violation.$id,
                      data: {"status": "Rejected"},
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User Blocked & Violations Cancelled')),
                  );

                  Navigator.pop(context); // Close dialog
                } catch (e) {
                  print('Error blocking user or cancelling violations: $e');
                }
              },
              child: Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final violation = widget.violation;

    return Scaffold(
      appBar: AppBar(title: Text('Violation Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Violation Type: ${violation.data['violation_type'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),

                  // User Details Section
                  userDetails != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Submitted by:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Name: ${userDetails!['name'] ?? 'Unknown'}"),
                            Text("Phone: ${userDetails!['phone'] ?? 'Unknown'}"),
                            Text("Email: ${userDetails!['email'] ?? 'Unknown'}"),
                            SizedBox(height: 16),
                          ],
                        )
                      : Text("User details not found"),

                  Text("Vehicle No: ${violation.data['vehicle_no'] ?? 'N/A'}"),
                  Text("Location: ${violation.data['location'] ?? 'N/A'}"),
                  Text("Date: ${violation.data['date'] ?? 'N/A'}"),
                  Text("Time: ${violation.data['time'] ?? 'N/A'}"),
                  Text("Comment: ${violation.data['comment'] ?? 'No Comment'}"),
                  SizedBox(height: 16),
                  Text("Status: ${violation.data['status'] ?? 'Pending'}",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  SizedBox(height: 16),

                  // Display Image if available
                  violation.data['image_id'] != null
                      ? Image.network(
                          "https://cloud.appwrite.io/v1/storage/buckets/67c3ece6001c2b68828b/files/${violation.data['image_id']}/preview?project=67c345160023bc7bcb88",
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Text("No Image Available"),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: () => approveViolation(violation.$id), child: Text("Approve")),
                      ElevatedButton(onPressed: () => rejectViolation(violation.$id), child: Text("Reject")),
                    ],
                  ),
                  ElevatedButton(onPressed: () => blockUser(violation.data['user_id']), child: Text("Block User")),
                ],
              ),
      ),
    );
  }
}
