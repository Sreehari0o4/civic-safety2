import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'home_page.dart'; // Import the Home Page
import 'dart:io';
import 'dart:typed_data'; // For storing image data
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart'; // For web file handling

class ReportViolationPage extends StatefulWidget {
  final Client client;

  ReportViolationPage({required this.client});

  @override
  _ReportViolationPageState createState() => _ReportViolationPageState();
}

class _ReportViolationPageState extends State<ReportViolationPage> {
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? _selectedViolationType;
  File? _imageFile; // Mobile file
  Uint8List? _imageBytes; // Web and Mobile bytes
  String? _fileName; // Store selected file name
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Violation types
  final List<String> _violationTypes = [
    'Over-speeding',
    'Unauthorized Parking',
    'Reckless Driving',
    'Signal Jumping',
    'Other',
  ];

  // Method to pick an image or video
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web: Use file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4'],
      );

      if (result != null) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
        });
      }
    } else {
      // Mobile: Use image_picker
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = File(pickedFile.path).readAsBytesSync(); // Convert to bytes
          _fileName = pickedFile.name;
        });
      }
    }
  }

  // Upload image to Appwrite
  Future<String?> _uploadImage() async {
    final storage = Storage(widget.client);

    try {
      if (_imageBytes == null || _fileName == null) {
        print('No image selected.');
        return null;
      }

      final response = await storage.createFile(
        bucketId: '67c3ece6001c2b68828b', // Replace with your bucket ID
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: _imageBytes!, filename: _fileName!),
      );

      print('File uploaded successfully. File ID: ${response.$id}');
      return response.$id; // Return the file ID
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _submitReport(BuildContext context) async {
  final account = Account(widget.client);

  try {
    // Fetch the current user
    final user = await account.get();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to report a violation.')),
      );
      return;
    }

    // Upload image if selected
    String? imageId;
    if (_imageBytes != null) {
      imageId = await _uploadImage();
      if (imageId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        return;
      }
    }

    // Prepare violation data
    final violation = {
      'vehicle_no': _vehicleNoController.text,
      'violation_type': _selectedViolationType,
      'location': _locationController.text,
      'date': _dateController.text,
      'time': _timeController.text,
      'comment': _commentController.text,
      'image_id': imageId,
      'user_id': user.$id, // Include the user's ID
    };

    // Submit violation to Appwrite database
    final databases = Databases(widget.client);
    await databases.createDocument(
      databaseId: '67c34dcb001fb8f9397d', // Replace with your database ID
      collectionId: '67c34dea000d11566fcc', // Replace with your collection ID
      documentId: ID.unique(),
      data: violation,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Violation Reported Successfully!')),
    );

    // Navigate back to the home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(client: widget.client)),
    );
  } catch (e) {
    print('Error submitting report: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to report violation: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Violation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Upload Image/Video Button
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  _imageBytes == null
                      ? 'Upload your file (image/video)'
                      : 'File Selected: $_fileName',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              // Display the selected image
              if (_imageBytes != null)
                Image.memory(
                  _imageBytes!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),
              // Vehicle Number Field
              TextField(
                controller: _vehicleNoController,
                decoration: InputDecoration(labelText: 'Vehicle no*', border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              // Violation Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedViolationType,
                decoration: InputDecoration(labelText: 'Violation Type', border: OutlineInputBorder()),
                items: _violationTypes.map((value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedViolationType = value),
              ),
              SizedBox(height: 20),
              // Location Field
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              // Date and Time Fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: 'Date (DD/MM/YYYY)', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(labelText: 'Time', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Comment Field
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(labelText: 'Comment', border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: () => _submitReport(context),
                child: Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}