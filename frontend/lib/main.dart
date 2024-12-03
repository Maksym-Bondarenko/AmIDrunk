import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import the home screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drunkenness Level Estimator',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set a primary color for the app
      ),
      home: HomeScreen(), // The first screen of the app
    );
  }
}
