import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../UI/global_timer_overlay.dart';

class ReactionTimeTestScreen extends StatefulWidget {
  @override
  _ReactionTimeTestScreenState createState() => _ReactionTimeTestScreenState();
}

class _ReactionTimeTestScreenState extends State<ReactionTimeTestScreen>
    with SingleTickerProviderStateMixin {
  static const int totalIterations = 20;
  final Random _random = Random();
  bool _testInProgress = false;
  int _currentIteration = 0;
  List<double> _reactionTimes = [];
  double? _circleX;
  double? _circleY;
  DateTime? _circleAppearedTime;
  Timer? _waitTimer;
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  bool _resultsShown = false;

  final List<Color> _possibleColors = [
    Color(0xFF12c2e9),
    Color(0xFFc471ed),
    Color(0xFFf64f59),
    Colors.cyan,
    Colors.yellowAccent
  ];

  double _testAreaWidth = 0;
  double _testAreaHeight = 0;
  double _circleDiameter = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _sizeAnimation = Tween<double>(begin: 60.0, end: 5.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _recordReaction(2.0);
        }
      });
    _colorAnimation = ColorTween(
      begin: _possibleColors.first,
      end: _possibleColors.last,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _testInProgress = true;
      _currentIteration = 0;
      _reactionTimes.clear();
      _resultsShown = false;
    });
    _startNextIteration();
  }

  void _startNextIteration() {
    if (_currentIteration >= totalIterations) {
      _finishTest();
      return;
    }
    Future.delayed(Duration(milliseconds: 500), _showCircle);
  }

  void _showCircle() {
    if (_testAreaWidth == 0 || _testAreaHeight == 0) return;

    // Ensure the circle is fully inside the test area, even at its largest size
    double maxX = _testAreaWidth - (_circleDiameter + 20);
    double maxY = _testAreaHeight - (_circleDiameter + 20);

    double posX = 10 + _random.nextDouble() * maxX;
    double posY = 10 + _random.nextDouble() * maxY;

    setState(() {
      _circleX = posX;
      _circleY = posY;
      _circleAppearedTime = DateTime.now();
    });

    _controller.reset();
    _controller.forward();
  }


  void _onCircleTap() {
    if (!_testInProgress || _circleAppearedTime == null) return;
    final reactionTime =
        DateTime.now().difference(_circleAppearedTime!).inMilliseconds / 1000.0;
    _recordReaction(reactionTime);
  }

  void _recordReaction(double time) {
    _reactionTimes.add(time);
    _currentIteration++;
    if (_currentIteration < totalIterations) {
      _startNextIteration();
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    if (_resultsShown) return;
    _resultsShown = true;
    setState(() {
      _testInProgress = false;
    });
    double avg = _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length;
    String state = _classifySobriety(avg);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResults(avg, state);
    });
  }

  String _classifySobriety(double avgTime) {
    if (avgTime < 0.7) return "Sober";
    if (avgTime < 1.0) return "Tipsy";
    if (avgTime < 1.5) return "Drunk";
    return "Very Drunk";
  }

  void _showResults(double avg, String state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Test Complete", style: GoogleFonts.pacifico()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Average reaction time: ${avg.toStringAsFixed(3)}s",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "You are: $state",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: state == "Sober"
                    ? Colors.green
                    : state == "Tipsy"
                    ? Colors.yellow
                    : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _testAreaWidth = screenWidth * 0.9;
    _testAreaHeight = screenHeight * 0.7;
    _circleDiameter = _testAreaWidth * 0.12;

    return Scaffold(
      appBar: AppBar(
        title: Text("Reaction Time Test",
            style: GoogleFonts.pacifico(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF3A3A3A),
      ),
      body: Stack(
        children: [
         Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Test Your Reaction Time! Tap the circle as fast as you can!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (_reactionTimes.isNotEmpty)
                    Text(
                      "Last: ${_reactionTimes.last.toStringAsFixed(3)}s | Avg: ${(_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).toStringAsFixed(3)}s",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            if (!_testInProgress)
              ElevatedButton(
                onPressed: _startTest,
                child: Text("Start Test",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            if (_testInProgress)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Container(
                      width: _testAreaWidth,
                      height: _testAreaHeight,
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.cyanAccent),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _possibleColors,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (_circleX != null && _circleY != null)
                            Positioned(
                              left: _circleX,
                              top: _circleY,
                              child: GestureDetector(
                                onTap: _onCircleTap,
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    return Container(
                                      width: _sizeAnimation.value,
                                      height: _sizeAnimation.value,
                                      decoration: BoxDecoration(
                                        color: _colorAnimation.value,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
          GlobalTimerOverlay(),
        ]
      ),
    );
  }
}
