import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // User Inputs
  String sex = "Male";
  double? age, height, weight, alcoholVolume, alcoholPercentage, targetPromille;

  // Calculation Results
  double? bmi, bac, timeToZero, timeToTarget;
  String? timeToZeroFormatted, timeToTargetFormatted;

  void calculateResults() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calculate BMI
      double heightInMeters = height! / 100;
      bmi = weight! / (heightInMeters * heightInMeters);

      // Calculate total body water using the Watson formula
      double bodyWater;
      if (sex == "Male") {
        bodyWater = 2.447 - 0.09516 * age! + 0.1074 * height! + 0.3362 * weight!;
      } else {
        bodyWater = -2.097 + 0.1069 * height! + 0.2466 * weight!;
      }

      // Calculate grams of alcohol in the body
      double alcoholInGrams =
          alcoholVolume! * (alcoholPercentage! / 100) * 0.789; // Alcohol density = 0.789 g/ml

      // Calculate BAC using the Widmark formula (as a percentage)
      bac = alcoholInGrams / (bodyWater * 1000); // BAC = g/L of blood

      // Convert BAC to promille for display purposes
      double promille = bac! * 10;

      // Time to reach 0 BAC (0.017% per hour burn rate)
      timeToZero = bac! / 0.017;

      // Time to reach target promille
      timeToTarget = (bac! - (targetPromille! / 10)) / 0.017;
      if (timeToTarget! < 0) timeToTarget = 0; // If already below target

      // Format times into readable format
      timeToZeroFormatted = _formatTime(timeToZero!);
      timeToTargetFormatted = _formatTime(timeToTarget!);

      // Update state with calculated values
      setState(() {
        bac = promille; // Update BAC to promille for display
      });
    }
  }

  String _formatTime(double hours) {
    int totalMinutes = (hours * 60).toInt();
    int days = totalMinutes ~/ (24 * 60);
    int remainingMinutes = totalMinutes % (24 * 60);
    int hrs = remainingMinutes ~/ 60;
    int mins = remainingMinutes % 60;

    if (days > 0) {
      return "$days day${days > 1 ? 's' : ''}, $hrs hour${hrs > 1 ? 's' : ''}, $mins minute${mins > 1 ? 's' : ''}";
    } else if (hrs > 0) {
      return "$hrs hour${hrs > 1 ? 's' : ''}, $mins minute${mins > 1 ? 's' : ''}";
    } else {
      return "$mins minute${mins > 1 ? 's' : ''}";
    }
  }

  void resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      sex = "Male";
      bmi = null;
      bac = null;
      timeToZero = null;
      timeToTarget = null;
      timeToZeroFormatted = null;
      timeToTargetFormatted = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alcohol Intoxication Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Age Input
              _buildNumberInput("Age", (value) => age = double.tryParse(value)),
              // Sex Dropdown
              _buildDropdownInput("Sex", ["Male", "Female"], (value) => sex = value!),
              // Height Input
              _buildNumberInput("Height (cm)", (value) => height = double.tryParse(value)),
              // Weight Input
              _buildNumberInput("Weight (kg)", (value) => weight = double.tryParse(value)),
              // Alcohol Volume Input
              _buildNumberInput("Alcohol Volume (ml)", (value) => alcoholVolume = double.tryParse(value)),
              // Alcohol Percentage Input
              _buildNumberInput("Alcohol Percentage (%)", (value) => alcoholPercentage = double.tryParse(value)),
              // Target Promille Input
              _buildNumberInput("Target Promille (e.g., 0.5‰)", (value) => targetPromille = double.tryParse(value)),
              SizedBox(height: 20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: calculateResults, child: Text("Calculate")),
                  ElevatedButton(onPressed: resetForm, child: Text("Reset")),
                ],
              ),
              SizedBox(height: 20),
              // Results
              if (bmi != null && bac != null && timeToZeroFormatted != null && timeToTargetFormatted != null) ...[
                Text("BMI: ${bmi!.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                Text("BAC: ${bac!.toStringAsFixed(2)}‰", style: TextStyle(fontSize: 18)),
                Text("Time to 0 Promille: $timeToZeroFormatted", style: TextStyle(fontSize: 18)),
                Text("Time to ${targetPromille!.toStringAsFixed(2)}‰: $timeToTargetFormatted", style: TextStyle(fontSize: 18)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
      onSaved: (value) => onSaved(value!),
    );
  }

  Widget _buildDropdownInput(String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: sex,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
