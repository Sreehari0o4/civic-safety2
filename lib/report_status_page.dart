import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class ReportStatusPage extends StatefulWidget {
  final Client client;

  ReportStatusPage({required this.client});

  @override
  _ReportStatusPageState createState() => _ReportStatusPageState();
}

class _ReportStatusPageState extends State<ReportStatusPage> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final databases = Databases(widget.client);
    final account = Account(widget.client);

    try {
      // Fetch the current user
      final user = await account.get();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to view reports.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch reports for the current user
      final response = await databases.listDocuments(
        databaseId: '67c34dcb001fb8f9397d', // Your database ID
        collectionId: '67c34dea000d11566fcc', // Your collection ID
        queries: [
          Query.equal('user_id', user.$id), // Filter by user ID
        ],
      );

      setState(() {
        reports = response.documents.map((doc) => doc.data).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch reports: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Status'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? Center(child: Text('No reports found.'))
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final violationType = report['violation_type'] ?? 'Unknown Violation';
                    final date = report['date'] ?? 'No Date';
                    final time = report['time'] ?? 'No Time';
                    final status = report['status'] ?? 'Pending';

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          violationType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: $date'),
                            Text('Time: $time'),
                            Text('Status: $status'),
                          ],
                        ),
                        trailing: Icon(
                          status == 'Approved'
                              ? Icons.check_circle
                              : status == 'Rejected'
                                  ? Icons.cancel
                                  : Icons.pending,
                          color: status == 'Approved'
                              ? Colors.green
                              : status == 'Rejected'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}