import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class RewardsPage extends StatefulWidget {
  final Client client;
  final String userId; // Current logged-in user's ID

  RewardsPage({required this.client, required this.userId});

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  late Databases databases;
  int totalEarnings = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    _fetchRewards();
  }

  // Fetch User's Total Reward Amount
  Future<void> _fetchRewards() async {
    setState(() => isLoading = true);

    try {
      final userDoc = await databases.getDocument(
        databaseId: '67c34dcb001fb8f9397d', // Main database ID
        collectionId: '67e808ac003001212055', // Users collection
        documentId: widget.userId, // Get reward data for logged-in user
      );

      setState(() {
        totalEarnings = userDoc.data['reward'] ?? 0; // Ensure reward is an int
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch rewards: $e')),
      );
    }
  }

  // Collect Reward Function
  Future<void> _collectReward() async {
    if (totalEarnings < 1000) { // Minimum withdrawal ₹10
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Minimum withdrawal amount is ₹10")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Withdrawal"),
          content: Text("Do you want to collect ₹${(totalEarnings / 100).toStringAsFixed(2)}?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () async {
                try {
                  // Reset user rewards to 0 after withdrawal
                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67e808ac003001212055', // Users collection
                    documentId: widget.userId,
                    data: {"reward": 0},
                  );

                  setState(() => totalEarnings = 0); // Update UI

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("₹${(totalEarnings / 100).toStringAsFixed(2)} collected successfully!")),
                  );

                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to collect reward: $e")),
                  );
                }
              },
              child: Text("Collect"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRewards, // Refresh reward data
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '₹${(totalEarnings / 100).toStringAsFixed(2)}', // Convert paise to rupees
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchRewards,
                          child: Text("Refresh"),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _collectReward,
                          child: Text("Collect Reward"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
