import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactionTimeTestScreen extends StatefulWidget {
  @override
  _ReactionTimeTestScreenState createState() => _ReactionTimeTestScreenState();
}

class _ReactionTimeTestScreenState extends State<ReactionTimeTestScreen> {
  static const int totalIterations = 20;
  final Random _random = Random();

  bool _testInProgress = false;
  bool _shouldShowCircle = false;
  int _currentIteration = 0;
  List<double> _reactionTimes = [];

  // Circle
  double? _circleX;
  double? _circleY;
  double _circleDiameter = 60.0;

  // Timing
  DateTime? _circleAppearedTime;
  Timer? _waitTimer;

  // Store constraints for positioning the circle
  BoxConstraints? _constraints;

  // Colors (distinguishable)
  final List<Color> _possibleColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.indigo
  ];
  Color _currentCircleColor = Colors.red;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _testInProgress = true;
      _currentIteration = 0;
      _reactionTimes.clear();
      _circleX = null;
      _circleY = null;
      _circleAppearedTime = null;
      _shouldShowCircle = true;
    });
  }

  void _startNextIteration() {
    if (_currentIteration >= totalIterations) {
      _finishTest();
      return;
    }
    setState(() {
      // Indicate that we want to show the next circle
      _shouldShowCircle = true;
      _circleX = null;
      _circleY = null;
      _circleAppearedTime = null;
    });
  }

  void _showCircle() {
    if (_constraints == null) return; // Should not happen if called correctly

    final constraints = _constraints!;
    double maxX = constraints.maxWidth - _circleDiameter;
    double maxY = constraints.maxHeight - _circleDiameter;

    if (maxX < 0) maxX = 0;
    if (maxY < 0) maxY = 0;

    double posX = _random.nextDouble() * maxX;
    double posY = _random.nextDouble() * maxY;

    Color color = _possibleColors[_random.nextInt(_possibleColors.length)];

    setState(() {
      _circleX = posX;
      _circleY = posY;
      _currentCircleColor = color;
      _circleAppearedTime = DateTime.now();
      _shouldShowCircle = false; // Circle shown, reset the flag
    });

    // Start a 2-second timer to record reaction if no tap
    _waitTimer?.cancel();
    _waitTimer = Timer(Duration(seconds: 2), () {
      if (_testInProgress && _currentIteration < totalIterations) {
        _recordReaction(2.0);
      }
    });
  }

  void _onCircleTap() {
    if (!_testInProgress || _circleAppearedTime == null) return;
    final reactionTime = DateTime.now().difference(_circleAppearedTime!).inMilliseconds / 1000.0;
    _recordReaction(reactionTime);
  }

  void _recordReaction(double time) {
    _waitTimer?.cancel();
    _reactionTimes.add(time);
    _currentIteration++;
    _startNextIteration();
  }

  void _finishTest() {
    setState(() {
      _testInProgress = false;
    });
    double avg = _reactionTimes.reduce((a,b) => a+b) / _reactionTimes.length;
    String state = _classifySobriety(avg);

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Test Complete"),
            content: Text("Average reaction time: ${avg.toStringAsFixed(3)}s\nYou are: $state"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("OK")
              )
            ],
          );
        }
    );
  }

  String _classifySobriety(double avgTime) {
    // Arbitrary thresholds
    if (avgTime < 0.7) return "Sober";
    if (avgTime < 1.0) return "Tipsy";
    if (avgTime < 1.5) return "Drunk";
    return "Very Drunk";
  }

  void _resetTest() {
    setState(() {
      _testInProgress = false;
      _currentIteration = 0;
      _reactionTimes.clear();
      _circleX = null;
      _circleY = null;
      _circleAppearedTime = null;
      _shouldShowCircle = false;
    });
  }

  Color _getReactionTimeColor(double rt) {
    return rt < 0.7 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reaction Time Test"),
        backgroundColor: Colors.deepPurple,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _constraints = constraints; // store constraints for circle placement
          // If test is in progress and we haven't shown a circle yet this iteration, do so now
          if (_testInProgress && _shouldShowCircle && _currentIteration < totalIterations) {
            // Show the circle as soon as we have constraints
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Note: If the user environment doesn't allow addPostFrameCallback at all,
              // we can directly call _showCircle here in setState:
              // but this might cause reentrancy issues if done directly in build.
              // We'll try calling it in a Future.microtask:
              Future.microtask(() => _showCircle());
            });
          }

          return Stack(
            children: [
              Positioned.fill(
                child: _buildContent(),
              ),
              // Circle on top if present
              if (_testInProgress && _circleX != null && _circleY != null)
                Positioned(
                  left: _circleX,
                  top: _circleY,
                  child: GestureDetector(
                    onTap: _onCircleTap,
                    child: Container(
                      width: _circleDiameter,
                      height: _circleDiameter,
                      decoration: BoxDecoration(
                        color: _currentCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    // Show last reaction time if available
    Widget lastReactionTimeWidget = Container();
    if (_reactionTimes.isNotEmpty) {
      double lastRT = _reactionTimes.last;
      lastReactionTimeWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Last Reaction Time: ${lastRT.toStringAsFixed(3)}s",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getReactionTimeColor(lastRT),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_testInProgress && _reactionTimes.isEmpty) {
      // Instructions before test start
      return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Test Your Reaction Time!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text("Instructions:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Press 'Start Test' to begin. A circle will appear at random places on the screen. "
                    "Tap it as quickly as possible. If you don't tap it within 2 seconds, it automatically moves on. "
                    "After 20 iterations, you'll see your average reaction time and a guess of your sobriety level."),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14)
                  ),
                  child: Text("Start Test", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_testInProgress && _currentIteration < totalIterations) {
      // During the test: show iteration info, last reaction time if any, and a cancel button
      return Column(
        children: [
          SizedBox(height: 16),
          lastReactionTimeWidget,
          Text("Iteration ${_currentIteration+1} of $totalIterations",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text("Tap the circle as fast as you can!", textAlign: TextAlign.center),
          SizedBox(height: 20),
          TextButton(
              onPressed: _resetTest,
              child: Text("Cancel Test", style: TextStyle(color: Colors.red))
          ),
          // The rest of the space is left empty so the circle can appear anywhere.
        ],
      );
    }

    // Test completed
    double avg = 0.0;
    if (_reactionTimes.isNotEmpty) {
      avg = _reactionTimes.reduce((a,b) => a+b) / _reactionTimes.length;
    }
    String state = _classifySobriety(avg);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              lastReactionTimeWidget,
              Text("Results",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text("Average Reaction Time: ${avg.toStringAsFixed(3)}s\nYou are: $state",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14)
                ),
                child: Text("Retest", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
