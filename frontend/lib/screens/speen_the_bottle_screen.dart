import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinTheBottleScreen extends StatefulWidget {
  @override
  _SpinTheBottleScreenState createState() => _SpinTheBottleScreenState();
}

class _SpinTheBottleScreenState extends State<SpinTheBottleScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  List<String> users = [];
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..addListener(() {
      setState(() {
        _currentRotation = _rotationAnimation.value;
      });
    });
  }

  void _addUser() {
    if (_userController.text.isNotEmpty && users.length < 10) {
      setState(() {
        users.add(_userController.text.trim());
      });
      _userController.clear();
    }
  }

  void _spinBottle() {
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one user!")),
      );
      return;
    }

    final random = Random();
    final targetRotation = (5 + random.nextDouble() * 5) * 2 * pi;

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _currentRotation = _currentRotation % (2 * pi);
      });
      String winner = users[random.nextInt(users.length)];
      _showWinnerDialog(winner);
    });
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Winner!", style: GoogleFonts.pacifico()),
          content: Text("The bottle points to: $winner"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Spin the Bottle", style: GoogleFonts.pacifico()),
        backgroundColor: Color(0xFF3A3A3A),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: "Enter Name",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Add Player", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (users.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: users.map((user) => Chip(label: Text(user))).toList(),
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _currentRotation,
                      child: Image.asset(
                        'assets/images/bottle.png',
                        width: screenWidth / 2,
                        height: screenWidth / 2,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Icon(Icons.arrow_drop_down, color: Colors.redAccent, size: 40),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: users.isNotEmpty ? _spinBottle : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: users.isNotEmpty ? Colors.deepPurple : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Spin the Bottle", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
