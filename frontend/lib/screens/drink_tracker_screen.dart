// File: drink_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure this import is present

class DrinkTrackerScreen extends StatefulWidget {
  @override
  _DrinkTrackerScreenState createState() => _DrinkTrackerScreenState();
}

class _DrinkTrackerScreenState extends State<DrinkTrackerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _drinkTypeController = TextEditingController();
  final TextEditingController _drinkAmountController = TextEditingController(); // in ml
  DateTime _selectedTime = DateTime.now();

  List<DrinkEntry> _drinkLog = [];

  double _dailyTotal = 0.0; // Total alcohol consumed today in ml

  @override
  void dispose() {
    _drinkTypeController.dispose();
    _drinkAmountController.dispose();
    super.dispose();
  }

  void _addDrink() {
    if (_formKey.currentState!.validate()) {
      final drinkType = _drinkTypeController.text.trim();
      final drinkAmount = double.parse(_drinkAmountController.text.trim());

      setState(() {
        _drinkLog.add(DrinkEntry(
          type: drinkType,
          amount: drinkAmount,
          time: _selectedTime,
        ));

        _dailyTotal += drinkAmount;
        _drinkTypeController.clear();
        _drinkAmountController.clear();
        _selectedTime = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Drink added successfully!")),
      );
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    // Filter drinks consumed today
    final today = DateTime.now();
    final drinksToday = _drinkLog.where((drink) {
      return drink.time.year == today.year &&
          drink.time.month == today.month &&
          drink.time.day == today.day;
    }).toList();

    double totalToday = drinksToday.fold(0.0, (sum, drink) => sum + drink.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text("Drink Tracker"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Drink Form
            Card(
              color: Colors.deepPurple[50],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Log Your Drink",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _drinkTypeController,
                        decoration: InputDecoration(
                          labelText: "Drink Type",
                          hintText: "e.g., Beer, Wine, Whiskey",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter the drink type";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _drinkAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount (ml)",
                          hintText: "e.g., 350",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter the drink amount";
                          }
                          final amount = double.tryParse(value.trim());
                          if (amount == null || amount <= 0) {
                            return "Please enter a valid amount";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Time Consumed:",
                              style: TextStyle(fontSize: 16, color: Colors.deepPurple[700]),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _selectTime(context),
                            child: Text(
                              DateFormat('hh:mm a').format(_selectedTime),
                              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addDrink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "Add Drink",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Daily Summary
            Card(
              color: Colors.deepPurple[50],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Consumption",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Total Drinks Consumed: ${drinksToday.length}",
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Total Alcohol Consumed: ${totalToday.toStringAsFixed(1)} ml",
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Drink Log List
            Card(
              color: Colors.deepPurple[50],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Drink Log",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (drinksToday.isEmpty)
                      Center(
                        child: Text(
                          "No drinks logged today.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: drinksToday.length,
                        itemBuilder: (context, index) {
                          final drink = drinksToday[index];
                          return ListTile(
                            leading: Icon(Icons.local_drink, color: Colors.deepPurple),
                            title: Text(drink.type, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${drink.amount.toStringAsFixed(1)} ml at ${_formatDateTime(drink.time)}"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _dailyTotal -= drink.amount;
                                  _drinkLog.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrinkEntry {
  final String type;
  final double amount; // in ml
  final DateTime time;

  DrinkEntry({
    required this.type,
    required this.amount,
    required this.time,
  });
}
