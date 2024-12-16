import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'registration_screen.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures the binding is initialized.
  runApp(const SankalpApp());
}

class SankalpApp extends StatelessWidget {
  const SankalpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sankalp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SankalpUI(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SankalpUI extends StatefulWidget {
  const SankalpUI({super.key});

  @override
  _SankalpUIState createState() => _SankalpUIState();
}

class _SankalpUIState extends State<SankalpUI>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // List of schemes with their details
  final List<Map<String, dynamic>> schemes = [
    {
      'name': 'Kisan Vikas Yojana',
      'details': '''
        Objective: Provide financial assistance to small and marginal farmers to enhance agricultural productivity.
        Introduced Date: January 15, 2024
        Last Date for Application: December 31, 2024
        Target Beneficiaries: Small and marginal farmers across India.
        Key Benefits:
          - Subsidized seeds and fertilizers.
          - Low-interest loans for agricultural equipment.
        Eligibility Criteria:
          - Must be a farmer with landholding of less than 5 acres.
          - Annual family income should not exceed INR 2 lakh.
        How to Apply: Eligible farmers can apply online via the official government portal or through designated local centers.
      ''',
    },
    {
      'name': 'Swasthya Suraksha Abhiyan',
      'details': '''
        Objective: Ensure access to affordable healthcare services in rural areas.
        Introduced Date: February 1, 2024
        Last Date for Application: November 30, 2024
        Target Beneficiaries: Rural residents, especially those below the poverty line.
        Key Benefits:
          - Free primary healthcare check-ups.
          - Subsidized medication and healthcare services at government hospitals.
        Eligibility Criteria:
          - Must reside in a rural area.
          - Household income should not exceed INR 1.5 lakh per annum.
        How to Apply: Beneficiaries can enroll at their local health centers or register online through the Swasthya Suraksha portal.
      ''',
    },
    // Add more schemes here if needed
  ];

  // Controller for text input in chatbot
  final TextEditingController _queryController = TextEditingController();

  // Form fields for the Services tab
  String? _selectedService;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Map to hold the dynamic controllers for each form field
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _queryController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sankalp"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: "Chatbot"),
            Tab(icon: Icon(Icons.document_scanner), text: "Services"),
            Tab(icon: Icon(Icons.new_releases), text: "New Schemes"),
          ],
        ),
      ),
      drawer: buildDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildChatbotTab(),
          buildServicesTab(),
          buildSchemesTab(),
        ],
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Sankalp App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Chat Bot'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Chat Bot'),
                    ),
                    body: buildChatbotTab(), // Embed the existing widget here
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Services'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Services'),
                    ),
                    body: buildServicesTab(), // Embed the existing widget here
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Schemes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Schemes'),
                    ),
                    body: buildSchemesTab(), // Embed the existing widget here
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              // Navigate to the registration screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to submit the form data to the backend
  // Function to submit the form data to the backend
  Future<void> submitForm(
      Map<String, String> formData, String certificateType) async {
    // Check if any field is empty
    for (var field in formData.values) {
      if (field.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('None of the fields can be left empty!')),
        );
        return;
      }
    }

    // Proceed to send data to the backend if no fields are empty
    final url =
        Uri.parse('http://localhost:8080/save-certificate'); // Backend URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'certificateType': certificateType,
        'fields': formData,
      }),
    );

    if (response.statusCode == 200) {
      // Parse the response to extract the unique ID
      final responseData = json.decode(response.body);
      final certificateId = responseData['certificateId'];

      // Show success message with the unique ID
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '$certificateType has been successfully saved! ID: $certificateId')));

      // Clear the form fields
      for (var controller in controllers.values) {
        controller.clear();
      }

      setState(() {
        _selectedService = null; // Reset the selected certificate type
      });
    } else {
      // Show failure message
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save data!')));
    }
  }

  // Chatbot Tab
  Widget buildChatbotTab() {
    String responseMessage = "";

    String getResponse(String query) {
      if (query.toLowerCase().contains("scheme")) {
        return "Here are some schemes you might be interested in: Kisan Vikas Yojana, Swasthya Suraksha Abhiyan.";
      }
      return "I didn't understand your query. Please try again.";
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  labelText: 'Enter your query',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        responseMessage = getResponse(_queryController.text);
                      });
                      _queryController.clear();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  responseMessage.isNotEmpty
                      ? responseMessage
                      : "Ask a question about schemes or services!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Services Tab - to fill the form
  Widget buildServicesTab() {
    final Map<String, List<String>> certificateFields = {
      "Birth Certificate": [
        "Full Name",
        "Date of Birth",
        "Time of Birth",
        "Place of Birth",
        "Gender",
        "Father's Name",
        "Mother's Name",
        "Blood Group"
      ],
      "Death Certificate": [
        "Name",
        "Date of Birth",
        "Age at Death",
        "Gender",
        "Address"
      ],
      "Land Certificate": [
        "Property Information",
        "Property Address",
        "Property Description",
        "Property Value",
        "Property Title",
        "Seller's Name",
        "Seller's Address",
        "Buyer's Name",
        "Buyer's Address"
      ],
      "Income Certificate": [
        "Name",
        "Date of Birth",
        "Gender",
        "Address",
        "Phone Number",
        "Email Address",
        "Annual Income",
        "Source of Income",
        "Income Tax Returns",
        "Bank Account Details"
      ]
    };

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Select Certificate'),
                  items: [
                    "Birth Certificate",
                    "Death Certificate",
                    "Land Certificate",
                    "Income Certificate"
                  ].map((certificate) {
                    return DropdownMenuItem<String>(
                      value: certificate,
                      child: Text(certificate),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                      controllers.clear(); // Clear previous inputs
                    });
                  },
                  hint: const Text("Select Certificate"),
                ),
                if (_selectedService != null)
                  Column(
                    children: [
                      for (var field in certificateFields[_selectedService!]!)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: controllers[field] ??=
                                TextEditingController(),
                            decoration: InputDecoration(
                              labelText: field,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedService != null) {
                            Map<String, String> formData = {};
                            for (var field
                                in certificateFields[_selectedService!]!) {
                              formData[field] = controllers[field]?.text ?? '';
                            }
                            await submitForm(formData, _selectedService!);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Schemes Tab - displays a list of schemes
  Widget buildSchemesTab() {
    return ListView.builder(
      itemCount: schemes.length,
      itemBuilder: (context, index) {
        final scheme = schemes[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme['name'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  scheme['details'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
