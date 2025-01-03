import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flask API Integration',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _response = '';
  String _uploadStatus = '';

  Future<void> sendQuery() async {
    final url = Uri.parse(
        'http://192.168.1.11:8080/ask_pdf'); // Update with your API URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': _queryController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['answer'];
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  Future<void> uploadPDF() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      final file = result.files.single;
      final url = Uri.parse('http://192.168.1.11:8080/pdf'); // Your API URL
      final request = http.MultipartRequest('POST', url);

      // Attach the selected file to the request
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = jsonDecode(responseData);

          // Check if the filename field is present in the server response
          final uploadedFileName = data['filename'] ?? 'Unknown';

          setState(() {
            _uploadStatus = 'Upload Successful: $uploadedFileName';
          });
        } else {
          setState(() {
            _uploadStatus = 'Upload Failed: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _uploadStatus = 'Error: $e';
        });
      }
    } else {
      setState(() {
        _uploadStatus = 'No file selected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flask API Integration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Enter Query',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: sendQuery,
                child: Text('Send Query'),
              ),
              SizedBox(height: 20),
              const Text(
                'Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(_response),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadPDF,
                child: Text('Upload PDF'),
              ),
              SizedBox(height: 10),
              const Text(
                'Upload Status:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(_uploadStatus),
            ],
          ),
        ),
      ),
    );
  }
}
