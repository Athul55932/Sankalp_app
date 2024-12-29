import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp()); // Add const here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Pass key to the super constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User  Registration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Pass key to the super constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")), // Add const here
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text("Go to Registration"), // Add const here
        ),
      ),
    );
  }
}
