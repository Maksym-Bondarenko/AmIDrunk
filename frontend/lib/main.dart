// File: main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/timer_provider.dart';
import 'screens/home_screen.dart';
// Import other screens as needed

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        // Add other providers if necessary
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmIDrunk?!',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(),
      // Define routes if using named navigation
    );
  }
}
