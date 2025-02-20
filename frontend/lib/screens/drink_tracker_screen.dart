import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../UI/global_timer_overlay.dart';

class DrinkTrackerScreen extends StatefulWidget {
  @override
  _DrinkTrackerScreenState createState() => _DrinkTrackerScreenState();
}

class _DrinkTrackerScreenState extends State<DrinkTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _drinkTypeController = TextEditingController();
  final TextEditingController _drinkAmountController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  List<DrinkEntry> _drinkLog = [];

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
        _drinkLog.add(DrinkEntry(type: drinkType, amount: drinkAmount, time: _selectedTime));
        _drinkTypeController.clear();
        _drinkAmountController.clear();
        _selectedTime = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Drink added successfully!")));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Drink Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDrinkForm(),
                SizedBox(height: 24),
                _buildDrinkLog(),
              ],
            ),
          ),
          GlobalTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildDrinkForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_drinkTypeController, "Drink Type", "e.g., Beer, Wine"),
              SizedBox(height: 16),
              _buildTextField(_drinkAmountController, "Amount (ml)", "e.g., 350", TextInputType.number),
              SizedBox(height: 16),
              _buildTimePicker(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addDrink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Add Drink", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Please enter $label";
        if (keyboardType == TextInputType.number && double.tryParse(value.trim()) == null) return "Please enter a valid number";
        return null;
      },
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Time Consumed:", style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
        TextButton(
          onPressed: () => _selectTime(context),
          child: Text(DateFormat('hh:mm a').format(_selectedTime), style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
        ),
      ],
    );
  }

  Widget _buildDrinkLog() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Drink Log", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 16),
            _drinkLog.isEmpty
                ? Center(child: Text("No drinks logged yet.", style: TextStyle(fontSize: 16, color: Colors.grey[700])))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _drinkLog.length,
              itemBuilder: (context, index) {
                final drink = _drinkLog[index];
                return ListTile(
                  leading: Icon(Icons.local_drink, color: Colors.deepPurple),
                  title: Text(drink.type, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${drink.amount.toStringAsFixed(1)} ml at ${_formatDateTime(drink.time)}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
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
    );
  }
}

class DrinkEntry {
  final String type;
  final double amount;
  final DateTime time;
  DrinkEntry({required this.type, required this.amount, required this.time});
}
