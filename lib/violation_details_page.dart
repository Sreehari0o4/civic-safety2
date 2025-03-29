import 'dart:typed_data';

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
  late Storage storage;
  Map<String, dynamic>? userDetails;
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    storage = Storage(widget.client);
    _fetchDetails();
  }

  // Fetch user details and image URL
  Future<void> _fetchDetails() async {
    String userId = widget.violation.data['user_id'] ?? '';
    String imageId = widget.violation.data['image_id'] ?? '';

    try {
      // Fetch user details
      if (userId.isNotEmpty) {
        final userDoc = await databases.getDocument(
          databaseId: '67c34dcb001fb8f9397d',
          collectionId: '67e808ac003001212055', // Users collection
          documentId: userId,
        );
        setState(() => userDetails = userDoc.data);
      }

      // Fetch image URL using `image_id`
      if (imageId.isNotEmpty) {
        print("Fetching image with ID: $imageId");
        final endpoint = widget.client.endPoint; // Appwrite endpoint
        final projectId = widget.client.config['project']; // Appwrite project ID
        final bucketId = '67c3ece6001c2b68828b'; // Your bucket ID

        // Construct the image URL manually
        final fileViewUrl = '$endpoint/storage/buckets/$bucketId/files/$imageId/view?project=$projectId';
        print("Constructed Image URL: $fileViewUrl");

        setState(() => imageUrl = fileViewUrl);
      } else {
        print("No image ID found in violation data.");
      }
    } catch (e) {
      print("Error fetching details: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final violation = widget.violation;

    return Scaffold(
      appBar: AppBar(title: Text('Violation Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Violation Type: ${violation.data['violation_type'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Location: ${violation.data['location'] ?? 'Unknown'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Date: ${violation.data['date'] ?? 'Unknown'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Time: ${violation.data['time'] ?? 'Unknown'}", // Added time field
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),

                  // Show Violation Image
                  imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'Error loading image',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            },
                          ),
                        )
                      : Text("No image available", style: TextStyle(color: Colors.grey)),

                  SizedBox(height: 20),

                  // User Details Section
                  userDetails != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Submitted by:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text("Name: ${userDetails!['name'] ?? 'Unknown'}"),
                            Text("Phone: ${userDetails!['phone'] ?? 'Unknown'}"),
                            Text("Email: ${userDetails!['email'] ?? 'Unknown'}"),
                            SizedBox(height: 16),
                          ],
                        )
                      : Text("User details not found"),

                  SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => approveViolation(violation.$id, violation.data['user_id']),
                        child: Text("Approve"),
                      ),
                      ElevatedButton(
                        onPressed: () => rejectViolation(violation.$id),
                        child: Text("Reject"),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => blockUser(violation.data['user_id']),
                    child: Text("Block User"),
                  ),
                ],
              ),
            ),
    );
  }

  // Approve Violation
  Future<void> approveViolation(String documentId, String userId) async {
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
                    int fineAmount = (double.parse(fineController.text) * 100).toInt();
                    int rewardAmount = (fineAmount * 0.1).toInt(); // 10% reward

                    await databases.updateDocument(
                      databaseId: '67c34dcb001fb8f9397d',
                      collectionId: '67c34dea000d11566fcc',
                      documentId: documentId,
                      data: {"status": "Approved", "amount": fineAmount},
                    );

                    final userDoc = await databases.getDocument(
                      databaseId: '67c34dcb001fb8f9397d',
                      collectionId: '67e808ac003001212055',
                      documentId: userId,
                    );
                    int currentReward = userDoc.data['reward'] ?? 0;

                    await databases.updateDocument(
                      databaseId: '67c34dcb001fb8f9397d',
                      collectionId: '67e808ac003001212055',
                      documentId: userId,
                      data: {"reward": currentReward + rewardAmount},
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Violation Approved & ₹${rewardAmount / 100} reward added')),
                    );
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

  // Block User
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
                  // Block the user
                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67e808ac003001212055',
                    documentId: userId,
                    data: {"blocked": true},
                  );

                  // Cancel all submitted violations
                  final violationsResponse = await databases.listDocuments(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67c34dea000d11566fcc',
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

                  Navigator.pop(context);
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
}

extension on Future<Uint8List> {
  String? get href => null;
}
