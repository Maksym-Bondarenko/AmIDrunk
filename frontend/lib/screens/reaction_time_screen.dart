import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactionTimeScreen extends StatefulWidget {
  @override
  _ReactionTimeScreenState createState() => _ReactionTimeScreenState();
}

class _ReactionTimeScreenState extends State<ReactionTimeScreen> {
  bool isTestStarted = false;
  bool isCircleVisible = false;
  Offset? circlePosition;
  Timer? displayTimer;
  Stopwatch stopwatch = Stopwatch();
  List<double> reactionTimes = [];
  int iteration = 0;
  Random random = Random();
  Color circleColor = Colors.blue; // Initial color

  final double circleDiameter = 50;

  @override
  void dispose() {
    displayTimer?.cancel();
    super.dispose();
  }

  void startTest() {
    setState(() {
      isTestStarted = true;
      iteration = 0;
      reactionTimes.clear();
    });
    _showNextCircle();
  }

  void _showNextCircle() {
    if (iteration >= 20) {
      _showResults();
      return;
    }

    // Define a restricted area for circles
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double restrictedWidth = screenWidth * 0.8; // 80% of screen width
    final double restrictedHeight = screenHeight * 0.6; // 60% of screen height
    final double restrictedXStart = (screenWidth - restrictedWidth) / 2;
    final double restrictedYStart = (screenHeight - restrictedHeight) / 2;

    // Randomly generate the circle's position within the restricted area
    final double x = random.nextDouble() * (restrictedWidth - circleDiameter) + restrictedXStart;
    final double y = random.nextDouble() * (restrictedHeight - circleDiameter) + restrictedYStart;

    setState(() {
      isCircleVisible = true;
      circlePosition = Offset(x, y);
      circleColor = _generateRandomColor(); // Generate a new random color
    });

    stopwatch.reset();
    stopwatch.start();

    // Timer to hide circle if not tapped within 2 seconds
    displayTimer?.cancel();
    displayTimer = Timer(Duration(seconds: 2), () {
      if (isCircleVisible) {
        _recordReactionTime(2000); // Timeout, record max reaction time
        _hideCircle();
        Future.delayed(Duration(milliseconds: 500), _showNextCircle);
      }
    });
  }

  void _onCircleTapped() {
    if (!isCircleVisible) return;

    stopwatch.stop();
    final reactionTime = stopwatch.elapsedMilliseconds.toDouble();
    _recordReactionTime(reactionTime);
    _hideCircle();
    Future.delayed(Duration(milliseconds: 500), _showNextCircle);
  }

  void _recordReactionTime(double reactionTime) {
    setState(() {
      reactionTimes.add(reactionTime);
      iteration++;
    });
  }

  void _hideCircle() {
    setState(() {
      isCircleVisible = false;
    });
  }

  void _showResults() {
    double averageTime = reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;

    String sobrietyLevel;
    if (averageTime < 500) {
      sobrietyLevel = "Sober";
    } else if (averageTime < 1000) {
      sobrietyLevel = "Tipsy";
    } else {
      sobrietyLevel = "Drunk";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Results"),
        content: Text(
          "Average Reaction Time: ${averageTime.toStringAsFixed(1)} ms\nSobriety Level: $sobrietyLevel",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isTestStarted = false;
              });
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Color _generateRandomColor() {
    return Color.fromARGB(
      255,
      50 + random.nextInt(206), // Avoid very low RGB values
      50 + random.nextInt(206),
      50 + random.nextInt(206),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reaction Time Test"),
      ),
      body: isTestStarted
          ? Stack(
        children: [
          // Restricted area with a visible border
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Stack(
                children: [
                  if (isCircleVisible && circlePosition != null)
                    Positioned(
                      left: circlePosition!.dx, // Ensure the circle fits
                      top: circlePosition!.dy,
                      child: GestureDetector(
                        onTap: _onCircleTapped,
                        child: Container(
                          width: circleDiameter,
                          height: circleDiameter,
                          decoration: BoxDecoration(
                            color: circleColor, // Random color
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Text(
              "Iteration: ${iteration + 1}/20",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          onPressed: startTest,
          child: Text("Start Test"),
        ),
      ),
    );
  }
}
