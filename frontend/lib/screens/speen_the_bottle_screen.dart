import 'dart:math';
import 'package:flutter/material.dart';

class SpinTheBottleScreen extends StatefulWidget {
  @override
  _SpinTheBottleScreenState createState() => _SpinTheBottleScreenState();
}

class _SpinTheBottleScreenState extends State<SpinTheBottleScreen> with SingleTickerProviderStateMixin {
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
        users.add(_userController.text);
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
      appBar: AppBar(title: Text("Spin the Bottle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Users Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "Enter Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _addUser, child: Text("Add")),
              ],
            ),
            SizedBox(height: 16),
            // Display Users List
            if (users.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: users
                    .map((user) => Chip(
                  label: Text(user),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      users.remove(user);
                    });
                  },
                ))
                    .toList(),
              ),
            SizedBox(height: 20),
            // Spin the Bottle Section
            Expanded(
              child: Center(
                child: Transform.rotate(
                  angle: _currentRotation,
                  child: Image.asset(
                    'assets/images/bottle.png', // Replace with your bottle image
                    width: screenWidth / 3,
                    height: screenWidth / 3,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _spinBottle,
              child: Text("Spin the Bottle"),
            ),
          ],
        ),
      ),
    );
  }
}
