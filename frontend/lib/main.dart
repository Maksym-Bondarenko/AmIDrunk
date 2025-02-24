import 'package:am_i_drank/services/session_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/timer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SessionStateProvider()),
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
        scaffoldBackgroundColor: Color(0xFF4A4A4A),
        primaryColor: Colors.deepPurpleAccent,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 18,
            letterSpacing: 1.2, // Helps distribute gradient better
            fontWeight: FontWeight.w600,
            foreground: Paint()..shader = _getGradientShader(500.0),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
            foreground: Paint()..shader = _getGradientShader(300.0),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF3A3A3A),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.5,
            foreground: Paint()..shader = _getGradientShader(500.0),
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
                width: 4,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }

  /// Generates a smooth gradient shader with a vibrant color range
  Shader _getGradientShader(double width) {
    return LinearGradient(
      colors: [
        Color(0xFFFF0000), // Red
        Color(0xFFFF8C00), // Dark Orange
        Color(0xFFFFD700), // Gold
        Color(0xFF00FF00), // Lime Green
        Color(0xFF00FA9A), // Medium Spring Green
        Color(0xFF00CED1), // Dark Turquoise
        Color(0xFF1E90FF), // Dodger Blue
        Color(0xFF8A2BE2), // Blue Violet
        Color(0xFFFF1493), // Deep Pink
        Color(0xFFDC143C), // Crimson
      ],
    ).createShader(Rect.fromLTWH(0.0, 0.0, width, 0.0));
  }
}