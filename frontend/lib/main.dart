import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/timer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF4A4A4A), // Even lighter gray
        primaryColor: Colors.deepPurpleAccent,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.pink, Colors.cyan, Colors.lightBlueAccent, Colors.greenAccent, Colors.blue, Colors.purpleAccent, Colors.yellow],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 0.0)),
            fontSize: 18,
          ),
          bodyMedium: TextStyle(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.pink, Colors.cyan, Colors.lightBlueAccent, Colors.greenAccent, Colors.blue, Colors.purpleAccent, Colors.yellow],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 0.0)),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF3A3A3A),
          elevation: 0,
          titleTextStyle: TextStyle(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.pink, Colors.cyan, Colors.lightBlueAccent, Colors.greenAccent, Colors.blue, Colors.purpleAccent, Colors.yellow],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 0.0)),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                width: 4, // Make border single and bold
                color: Colors.transparent, // Set transparent to apply gradient manually
              ),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
