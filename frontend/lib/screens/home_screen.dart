// File: home_screen.dart

import 'package:am_i_drank/screens/speen_the_bottle_screen.dart';
import 'package:flutter/material.dart';
import '../UI/global_timer_overlay.dart';
import 'reaction_time_screen.dart';
import 'drink_tracker_screen.dart';
import 'calculator_screen.dart';
import 'camera_screen.dart';
import 'endless_runner_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Determine the number of columns based on screen width for responsiveness
    int getCrossAxisCount(double width) {
      if (width >= 1200) return 4;
      if (width >= 800) return 3;
      return 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Drunkenness Estimator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = getCrossAxisCount(constraints.maxWidth);
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Welcome Header
                    Card(
                      color: Colors.deepPurple[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_drink,
                              size: 60,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Welcome to the Drunkenness Estimator!\nChoose a tool below to get started.",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Grid of Menu Buttons
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuButton(
                          context,
                          title: "Alcohol Calculator",
                          icon: Icons.calculate,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AlcoholCalculationScreen()),
                            );
                          },
                        ),
                        _buildMenuButton(
                          context,
                          title: "Reaction Time Test",
                          icon: Icons.timer,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReactionTimeTestScreen()),
                            );
                          },
                        ),
                        _buildMenuButton(
                          context,
                          title: "Endless Runner",
                          icon: Icons.directions_run,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EndlessRunnerScreen()),
                            );
                          },
                        ),
                        _buildMenuButton(
                          context,
                          title: "Spin the Bottle",
                          icon: Icons.sports_bar,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SpinTheBottleScreen()),
                            );
                          },
                        ),
                        _buildMenuButton(
                          context,
                          title: "Alco-Camera",
                          icon: Icons.camera_alt,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CameraScreen()),
                            );
                          },
                        ),
                        _buildMenuButton(
                          context,
                          title: "Drink Tracker",
                          icon: Icons.list_alt,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DrinkTrackerScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Optional: Add a footer or additional information
                    Text(
                      "© 2024 Drunkenness Estimator. Developed by LORD MAX. All rights reserved.",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          // Global Timer Overlay
          GlobalTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Splash color
        shadowColor: Colors.deepPurpleAccent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.white,
          ),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
