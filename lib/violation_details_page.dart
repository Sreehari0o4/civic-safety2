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
  final TextEditingController fineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
  }

  // Approve with Fine Amount
  Future<void> approveViolation(String documentId) async {
  TextEditingController fineController = TextEditingController(); // Create a controller for input

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Fine Amount'),
        content: TextField(
          controller: fineController,
          keyboardType: TextInputType.number, // Ensures only numeric input
          decoration: InputDecoration(hintText: "Enter fine amount"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (fineController.text.isNotEmpty) {
                try {
                  final document = await databases.getDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67c34dea000d11566fcc',
                    documentId: documentId,
                  );

                  // Ensure user_id is not null
                  String existingUserId = document.data['user_id'] ?? "";

                  // Convert fine amount to double
                  double fineAmount = double.tryParse(fineController.text) ?? 0.0;

                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67c34dea000d11566fcc',
                    documentId: documentId,
                    data: {
                      "status": "Approved",
                      "amount": fineAmount, // Pass as double
                      "user_id": existingUserId, // Ensure user_id is preserved
                    },
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Violation Approved')),
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
  try {
    // Fetch the existing document to get the user_id
    final document = await databases.getDocument(
      databaseId: '67c34dcb001fb8f9397d',
      collectionId: '67c34dea000d11566fcc',
      documentId: documentId,
    );

    String existingUserId = document.data['user_id']; // Keep unchanged

    await databases.updateDocument(
      databaseId: '67c34dcb001fb8f9397d',
      collectionId: '67c34dea000d11566fcc',
      documentId: documentId,
      data: {
        "status": "Cancelled",
        "user_id": existingUserId, // Keep the original user_id
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Violation Rejected')),
    );
    Navigator.pop(context);
  } catch (e) {
    print('Error rejecting violation: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    final violation = widget.violation;

    return Scaffold(
      appBar: AppBar(title: Text('Violation Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Violation Type: ${violation.data['violation_type'] ?? 'N/A'}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
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

            // Buttons to Approve or Reject
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => approveViolation(violation.$id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Approve"),
                ),
                ElevatedButton(
                  onPressed: () => rejectViolation(violation.$id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
