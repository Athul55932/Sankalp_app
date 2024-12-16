import 'package:flutter/material.dart';
import 'registration_screen.dart'; // Import the registration screen
import 'dart:convert';
import 'package:http/http.dart' as http;

// AdminScreen widget
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const AdminDashboard(),
      drawer: const AdminDrawer(),
    );
  }
}

// AdminDrawer widget
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Admin Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Manage Certificates'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCertificates(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('View Statistics'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// AdminDashboard widget
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Text(
              'Welcome to the Admin Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text('Pending User Requests'),
                subtitle: const Text('Manage user registration requests'),
                trailing: const Icon(Icons.pending_actions),
                onTap: () {
                  // Add navigation to user requests screen
                },
              ),
            ),
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text('Manage Certificates'),
                subtitle: const Text('Approve or reject certificate requests'),
                trailing: const Icon(Icons.document_scanner),
                onTap: () {
                  // Add navigation to certificate management screen
                },
              ),
            ),
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text('View Statistics'),
                subtitle:
                    const Text('View the app usage and performance stats'),
                trailing: const Icon(Icons.bar_chart),
                onTap: () {
                  // Add navigation to statistics screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ManageCertificates StatefulWidget
class ManageCertificates extends StatefulWidget {
  const ManageCertificates({super.key});

  @override
  _ManageCertificatesState createState() => _ManageCertificatesState();
}

class _ManageCertificatesState extends State<ManageCertificates> {
  String? selectedCertificateType;
  List<Map<String, String>> fetchedData = [];

  Future<void> fetchCertificates(String certificateType) async {
    final url = Uri.parse('http://8080/fetchCertificates');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'certificateType': certificateType}),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchedData = List<Map<String, String>>.from(
          jsonDecode(response.body)
              .map((item) => Map<String, String>.from(item['fields'])),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Certificates')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Select Certificate'),
              items: [
                'Birth Certificate',
                'Death Certificate',
                'Land Certificate',
                'Income Certificate',
              ].map((certificate) {
                return DropdownMenuItem<String>(
                  value: certificate,
                  child: Text(certificate),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCertificateType = value;
                  fetchedData = []; // Clear previous data
                });
                if (value != null) fetchCertificates(value);
              },
              hint: const Text("Select Certificate"),
            ),
            const SizedBox(height: 20),
            if (fetchedData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: fetchedData.length,
                  itemBuilder: (context, index) {
                    final entry = fetchedData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text('Certificate ${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entry.entries.map((e) {
                            return Text('${e.key}: ${e.value}');
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
