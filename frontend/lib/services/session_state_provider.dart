import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStateProvider extends ChangeNotifier {
  Map<String, String> _drunkennessStates = {
    "Alcohol Calculator": "",
    "Reaction Time Test": "",
    "Alco-Camera": "",
  };

  Map<String, String> get drunkennessStates => _drunkennessStates;

  // Initialize from Local Storage
  SessionStateProvider() {
    _loadData();
  }

  /// LOAD DATA FROM STORAGE
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _drunkennessStates = {
      "Alcohol Calculator": prefs.getString("calculatorStatus") ?? "",
      "Reaction Time Test": prefs.getString("reactionStatus") ?? "",
      "Alco-Camera": prefs.getString("cameraStatus") ?? "",
    };
    notifyListeners(); // Notify UI after loading data
  }

  /// SAVE DATA TO STORAGE
  Future<void> saveDrunkennessState(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    _drunkennessStates[key] = value;
    notifyListeners(); // Notify UI to reflect changes
  }
}