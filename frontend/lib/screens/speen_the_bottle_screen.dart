import 'dart:math';
import 'package:flutter/material.dart';

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
  double _currentRotation = 0.0; // Tracks the current rotation angle

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 5), // Animation duration
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
    final targetRotation = (5 + random.nextDouble() * 5) * 2 * pi; // At least 5 full rotations

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0).then((_) {
      // Normalize the final rotation angle to the range [0, 2π]
      setState(() {
        _currentRotation = _currentRotation % (2 * pi);
      });

      // Select a random user
      String winner = users[random.nextInt(users.length)];
      // Show the winner in a dialog
      _showWinnerDialog(winner);
    });
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Winner!"),
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
        title: Text("Spin the Bottle"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.deepPurple[50],
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  "Spin the Bottle Game",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                // Add Users Section
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: "Enter Name",
                          hintText: "e.g., Alice",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Display Users List
                if (users.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: users
                          .map(
                            (user) => Chip(
                          label: Text(user),
                          backgroundColor: Colors.deepPurple[100],
                          deleteIcon: Icon(Icons.close, color: Colors.deepPurple),
                          onDeleted: () {
                            setState(() {
                              users.remove(user);
                            });
                          },
                        ),
                      )
                          .toList(),
                    ),
                  ),
                SizedBox(height: 24),
                // Spin the Bottle Section
                Column(
                  children: [
                    Text(
                      "Ready to spin?",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Bottle Image
                        Transform.rotate(
                          angle: _currentRotation,
                          child: Image.asset(
                            'assets/images/bottle.png', // Ensure this image exists in your assets
                            width: screenWidth / 2,
                            height: screenWidth / 2,
                          ),
                        ),
                        // Pointer
                        Positioned(
                          top: 0,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: users.isNotEmpty ? _spinBottle : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        users.isNotEmpty ? Colors.deepPurple : Colors.grey,
                        padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Spin the Bottle",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
