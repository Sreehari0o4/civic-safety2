import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'home_page.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:exif/exif.dart';

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
  final TextEditingController _otherViolationController = TextEditingController();

  String? _selectedViolationType;
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _fileName;
  String? _imageId;
  final ImagePicker _picker = ImagePicker();
  late Databases _database;
  late Storage _storage;
  late Account _account;
  String? _userId;

  final List<String> _violationTypes = [
    'Over-speeding',
    'Unauthorized Parking',
    'Reckless Driving',
    'Signal Jumping',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _database = Databases(widget.client);
    _storage = Storage(widget.client);
    _account = Account(widget.client);
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      final response = await _account.get();
      setState(() {
        _userId = response.$id;
      });
    } catch (e) {
      print('Error fetching user ID: $e');
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
        });
        await _extractMetadata(_imageBytes!);
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = File(pickedFile.path).readAsBytesSync();
          _fileName = pickedFile.name;
        });
        await _extractMetadata(File(pickedFile.path).readAsBytesSync());
      }
    }
  }

  Future<void> _extractMetadata(Uint8List imageBytes) async {
    try {
      final data = await readExifFromBytes(imageBytes);
      if (data.containsKey('EXIF DateTimeOriginal')) {
        String dateTime = data['EXIF DateTimeOriginal']!.toString();
        List<String> dateTimeParts = dateTime.split(' ');

        if (dateTimeParts.length == 2) {
          _dateController.text = dateTimeParts[0].replaceAll(':', '-');
          _timeController.text = dateTimeParts[1];
        }
      } else {
        _dateController.text = "No EXIF Date Found";
        _timeController.text = "No EXIF Time Found";
      }

      setState(() {});
    } catch (e) {
      print('Error extracting metadata: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null && _imageFile == null) return;

    try {
      final InputFile file = kIsWeb
          ? InputFile.fromBytes(bytes: _imageBytes!, filename: _fileName!)
          : InputFile.fromPath(path: _imageFile!.path);

      final response = await _storage.createFile(
        bucketId: '67c3ece6001c2b68828b',
        fileId: ID.unique(),
        file: file,
      );

      setState(() {
        _imageId = response.$id;
      });

      print('Image uploaded successfully! Image ID: $_imageId');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _submitReport() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in!')));
      return;
    }

    await _uploadImage();

    String violationType = _selectedViolationType == "Other" ? _otherViolationController.text : _selectedViolationType ?? "";

    try {
      await _database.createDocument(
        databaseId: '67c34dcb001fb8f9397d',
        collectionId: '67c34dea000d11566fcc',
        documentId: ID.unique(),
        data: {
          'vehicle_no': _vehicleNoController.text,
          'violation_type': violationType,
          'location': _locationController.text,
          'date': _dateController.text,
          'time': _timeController.text,
          'comment': _commentController.text,
          'user_id': _userId,
          'image_id': _imageId,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Violation Reported Successfully!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(client: widget.client)),
      );
    } catch (e) {
      print('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report violation.')));
    }
  }

  Future<void> _showConfirmationDialog() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to submit this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _submitReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Violation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(onPressed: _pickImage, child: Text('Upload Image')),
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.memory(_imageBytes!, height: 150, width: 150, fit: BoxFit.cover),
                ),
              TextField(controller: _vehicleNoController, decoration: InputDecoration(labelText: 'Vehicle No*')),
              DropdownButtonFormField<String>(
                value: _selectedViolationType,
                items: _violationTypes.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedViolationType = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Violation Type*'),
              ),
              TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Location*')),
              TextField(controller: _dateController, decoration: InputDecoration(labelText: 'Date'), readOnly: true),
              TextField(controller: _timeController, decoration: InputDecoration(labelText: 'Time'), readOnly: true),
              TextField(controller: _commentController, decoration: InputDecoration(labelText: 'Additional Comments')),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _showConfirmationDialog, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
