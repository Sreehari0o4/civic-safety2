import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class RewardsPage extends StatefulWidget {
  final Client client;

  RewardsPage({required this.client});

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> rewards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  Future<void> _fetchRewards() async {
    final databases = Databases(widget.client);

    try {
      final response = await databases.listDocuments(
        databaseId: 'rewards_db', // Your database ID
        collectionId: 'rewards', // Your collection ID
      );
      setState(() {
        rewards = response.documents.map((doc) => doc.data).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch rewards: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = rewards.fold(0, (sum, reward) {
      return sum + (reward['amount'] as int? ?? 0); // Ensure amount is treated as int
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Earnings: ₹$totalEarnings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Amount: ₹${reward['amount'] ?? '0'}'),
                          subtitle: Text('Date: ${reward['date'] ?? 'No Date'}'),
                          trailing: Icon(Icons.currency_rupee, color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}