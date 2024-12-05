import 'package:am_i_drank/screens/speen_the_bottle_screen.dart';
import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'camera_screen.dart';
import 'endless_runner_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drunkenness Estimator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Two columns of buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuButton("Busfahrer", Icons.bus_alert, () {}),
                  _buildMenuButton("King", Icons.videogame_asset, () {}),
                  _buildMenuButton("Endless Runner", Icons.directions_run, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EndlessRunnerScreen()),
                    );
                  }),
                  _buildMenuButton("Spin the Bottle", Icons.sports_bar, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpinTheBottleScreen()),
                    );
                  }),
                  _buildMenuButton("Alco-Calculator", Icons.calculate, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalculatorScreen()),
                    );
                  }),
                  _buildMenuButton("Start Alco-Camera", Icons.camera, () {
                    // Navigate to the Camera Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        backgroundColor: Colors.blue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
