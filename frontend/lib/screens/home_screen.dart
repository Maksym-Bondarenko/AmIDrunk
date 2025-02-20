import 'package:am_i_drank/screens/speen_the_bottle_screen.dart';
import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import '../UI/global_timer_overlay.dart';
import 'reaction_time_screen.dart';
import 'drink_tracker_screen.dart';
import 'calculator_screen.dart';
import 'camera_screen.dart';
import 'endless_runner_screen.dart';
import 'package:blur/blur.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool showBubbles = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerBubbles() {
    setState(() {
      showBubbles = true;
    });
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        showBubbles = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int getCrossAxisCount(double width) {
      if (width >= 1200) return 4;
      if (width >= 800) return 3;
      return 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                ).createShader(bounds);
              },
              child: Text(
                "Drunkenness Estimator",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.music_note, color: Colors.greenAccent),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF3A3A3A),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (showBubbles)
            Positioned.fill(
              child: FloatingBubbles(
                noOfBubbles: 20,
                colorsOfBubbles: [
                  Colors.green.withAlpha(30),
                  Colors.cyanAccent.withAlpha(30),
                  Colors.lightBlueAccent.withAlpha(30),
                  Colors.deepPurpleAccent.withAlpha(30),
                ],
                sizeFactor: 0.2,
                duration: 5,
                opacity: 70,
                paintingStyle: PaintingStyle.stroke,
                strokeWidth: 8,
                shape: BubbleShape.circle,
                speed: BubbleSpeed.normal,
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = getCrossAxisCount(constraints.maxWidth);
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _triggerBubbles,
                      child: Card(
                        color: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            width: 4,
                            color: Colors.transparent,
                          ),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              RotationTransition(
                                turns: _rotationAnimation,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    Icons.local_drink,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    "Welcome to the Drunkenness Estimator!\nChoose a tool below to get started.",
                                    style: GoogleFonts.pacifico(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuButton(context, "Alcohol Calculator", Icons.calculate, AlcoholCalculationScreen()),
                        _buildMenuButton(context, "Reaction Time Test", Icons.timer, ReactionTimeTestScreen()),
                        _buildMenuButton(context, "Endless Runner", Icons.directions_run, EndlessRunnerScreen()),
                        _buildMenuButton(context, "Spin the Bottle", Icons.sports_bar, SpinTheBottleScreen()),
                        _buildMenuButton(context, "Alco-Camera", Icons.camera_alt, CameraScreen()),
                        _buildMenuButton(context, "Drink Tracker", Icons.list_alt, DrinkTrackerScreen()),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          GlobalTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 4,
            color: Colors.transparent,
          ),
          gradient: LinearGradient(
            colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.7),
            shadowColor: Colors.transparent,
            padding: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                width: 4,
                color: Colors.transparent,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                  ).createShader(bounds);
                },
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
