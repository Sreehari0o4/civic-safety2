import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class BlockedUsersPage extends StatefulWidget {
  final Client client;

  BlockedUsersPage({required this.client});

  @override
  _BlockedUsersPageState createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late Databases databases;
  List<Document> blockedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    databases = Databases(widget.client);
    _fetchBlockedUsers();
  }

  // Fetch blocked users from the database
  Future<void> _fetchBlockedUsers() async {
    try {
      final response = await databases.listDocuments(
        databaseId: '67c34dcb001fb8f9397d',
        collectionId: '67e808ac003001212055', // Users collection
        queries: [Query.equal("blocked", true)],
      );

      setState(() {
        blockedUsers = response.documents;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching blocked users: $e");
      setState(() => isLoading = false);
    }
  }

  // Unblock User
  Future<void> _unblockUser(String userId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Unblock User"),
          content: Text("Are you sure you want to unblock this user?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  // Update user status to unblock
                  await databases.updateDocument(
                    databaseId: '67c34dcb001fb8f9397d',
                    collectionId: '67e808ac003001212055',
                    documentId: userId,
                    data: {"blocked": false},
                  );

                  // Remove user from the list
                  setState(() {
                    blockedUsers.removeWhere((user) => user.$id == userId);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User Unblocked')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  print("Error unblocking user: $e");
                }
              },
              child: Text('Unblock', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blocked Users')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : blockedUsers.isEmpty
              ? Center(child: Text("No blocked users"))
              : ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = blockedUsers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.person_off, color: Colors.red),
                        title: Text(user.data['name'] ?? 'Unknown User'),
                        subtitle: Text(user.data['email'] ?? 'No Email'),
                        trailing: ElevatedButton(
                          onPressed: () => _unblockUser(user.$id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: Text("Unblock"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
