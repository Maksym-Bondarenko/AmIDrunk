import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Am I Drunk?',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(), // Start with the Home Screen
    );
  }
}
