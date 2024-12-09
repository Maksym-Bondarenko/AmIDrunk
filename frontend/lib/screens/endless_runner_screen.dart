import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../games/endless_runner/beer_runner/main.dart';


class EndlessRunnerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MyGame(),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the main screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
