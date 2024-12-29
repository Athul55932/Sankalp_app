import 'package:flutter/material.dart';
import '../services/api_service.dart';  // Make sure to import your API service

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key}); // Add key parameter

  @override
  ChatScreenState createState() => ChatScreenState(); // Change to public state class
}

class ChatScreenState extends State<ChatScreen> { // Remove underscore to make it public
  final ApiService apiService = ApiService('https://your-api-url.com'); // Replace with your API URL
  final TextEditingController _controller = TextEditingController();
  String response = '';
  bool isLoading = false;

  void _sendQuery() async {
    if (_controller.text.isEmpty) return; // Prevent sending empty queries

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final query = _controller.text;
      final result = await apiService.fetchResponse(query);
      setState(() {
        response = result; // Update the response
        isLoading = false; // Hide loading indicator
      });
    } catch (e) {
      setState(() {
        response = 'Error: ${e.toString()}'; // Handle errors
        isLoading = false; // Hide loading indicator
      });
    }

    _controller.clear(); // Clear the input field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sankalp Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.isEmpty ? 'Ask me anything!' : response,
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (isLoading) const CircularProgressIndicator(), // Show loading indicator
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Type your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendQuery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}