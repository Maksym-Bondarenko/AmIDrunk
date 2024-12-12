// File: timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  Duration _remainingDuration = Duration.zero;
  bool _isActive = false;

  Duration get remainingDuration => _remainingDuration;
  bool get isActive => _isActive;

  void startTimer(Duration duration) {
    if (_isActive) {
      _timer?.cancel();
    }

    _remainingDuration = duration;
    _isActive = true;
    notifyListeners();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingDuration > Duration.zero) {
        _remainingDuration -= Duration(seconds: 1);
        notifyListeners();
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _remainingDuration = Duration.zero;
    _isActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
