import 'package:flutter/material.dart';

class AlcoholCalculationScreen extends StatefulWidget {
  @override
  _AlcoholCalculationScreenState createState() => _AlcoholCalculationScreenState();
}

class _AlcoholCalculationScreenState extends State<AlcoholCalculationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _weightController = TextEditingController(); // in kg
  final _heightController = TextEditingController(); // in cm
  final _alcoholAmountController = TextEditingController(); // volume in ml
  final _alcoholPercentageController = TextEditingController(); // in %

  // For sex selection
  String? _selectedSex;

  double _calculatedBAC = 0.0;
  double _timeToZero = 0.0;
  double _timeToLegalLimit = 0.0;
  double _bmi = 0.0;

  final double _legalLimit = 0.05; // example legal limit

  void _calculateBAC() {
    if (_formKey.currentState!.validate()) {
      final age = int.tryParse(_ageController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final alcoholVolume = double.tryParse(_alcoholAmountController.text) ?? 0.0;
      final alcoholPercent = double.tryParse(_alcoholPercentageController.text) ?? 0.0;

      final sex = _selectedSex == "Male" ? 'M' : 'F';

      // Distribution ratio r
      double r = (sex == 'M') ? 0.68 : 0.55;

      // Calculate grams of alcohol
      double gramsOfAlcohol = alcoholVolume * (alcoholPercent / 100.0) * 0.789;

      // weight in grams
      double weightGrams = weight * 1000.0;

      // BAC calculation (Widmark approximation)
      double bac = (gramsOfAlcohol / (weightGrams * r)) * 100;

      // Adjust elimination rate based on age
      double baseEliminationRate = 0.015; // base rate in g/dL per hour
      double ageAdjustment = 0.0001 * (age - 30); // hypothetical adjustment
      double adjustedEliminationRate = baseEliminationRate + ageAdjustment;

      // Ensure the elimination rate doesn't go below a certain threshold
      adjustedEliminationRate = adjustedEliminationRate.clamp(0.010, 0.020);

      // Time to metabolize
      double timeToZero = (bac > 0) ? bac / adjustedEliminationRate : 0.0;
      double timeToLegal = (bac > _legalLimit) ? (bac - _legalLimit) / adjustedEliminationRate : 0.0;

      // Calculate BMI
      double heightM = height / 100.0;
      double bmi = 0.0;
      if (heightM > 0) {
        bmi = weight / (heightM * heightM);
      }

      setState(() {
        _calculatedBAC = bac;
        _timeToZero = timeToZero;
        _timeToLegalLimit = timeToLegal;
        _bmi = bmi;
      });
    }
  }


  String _formatHours(double hours) {
    if (hours <= 0) {
      return "0 hours";
    }

    int totalMinutes = (hours * 60).floor();
    int days = totalMinutes ~/ (60 * 24);
    int remainder = totalMinutes % (60 * 24);
    int hrs = remainder ~/ 60;
    int mins = remainder % 60;

    String result = "";
    if (days > 0) {
      result += "$days day${days > 1 ? 's' : ''}";
      if (hrs > 0 || mins > 0) result += ", ";
    }
    if (hrs > 0) {
      result += "$hrs hour${hrs > 1 ? 's' : ''}";
      if (mins > 0) result += ", ";
    }
    if (mins > 0) {
      result += "$mins minute${mins > 1 ? 's' : ''}";
    }

    if (result.isEmpty) {
      result = "0 hours";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool showWarning = _calculatedBAC > 0.30; // Adjust this threshold as needed

    return Scaffold(
      appBar: AppBar(
        title: Text("Alcohol Level Estimator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Enter Your Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(_ageController, "Age (years)", "Enter your age", TextInputType.number),
                  SizedBox(height: 10),
                  _buildTextField(_weightController, "Weight (kg)", "Enter your weight in kg", TextInputType.number),
                  SizedBox(height: 10),
                  _buildSexDropdown(),
                  SizedBox(height: 10),
                  _buildTextField(_heightController, "Height (cm)", "Enter your height in cm", TextInputType.number),
                  SizedBox(height: 10),
                  _buildTextField(_alcoholAmountController, "Alcohol Amount (ml)", "Volume of alcohol consumed in ml", TextInputType.number),
                  SizedBox(height: 10),
                  _buildTextField(_alcoholPercentageController, "Alcohol % (ABV)", "Alcohol percentage (e.g. 40 for whiskey)", TextInputType.number),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _calculateBAC,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14)
                    ),
                    child: Text("Calculate", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  if (_calculatedBAC > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Results:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildResultRow("Estimated BAC:", "${_calculatedBAC.toStringAsFixed(3)} g/dL"),
                        _buildResultRow("Time until BAC = 0:", _formatHours(_timeToZero)),
                        _buildResultRow("Time until BAC ≤ ${_legalLimit.toStringAsFixed(2)}:", _formatHours(_timeToLegalLimit)),
                        _buildResultRow("BMI:", _bmi.toStringAsFixed(2)),
                        if (showWarning)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Warning: This level of intoxication is extremely dangerous!",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                      ],
                    )
                ],
              ),
            ),
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
        fillColor: Colors.grey[100],
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }

  Widget _buildSexDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSex,
      decoration: InputDecoration(
        labelText: "Sex",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Colors.grey[100],
        filled: true,
      ),
      items: [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSex = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select your sex";
        }
        return null;
      },
    );
  }

  Widget _buildResultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black87))
        ],
      ),
    );
  }
}
