// File: global_timer_overlay.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:am_i_drank/services/timer_provider.dart';

class GlobalTimerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        if (!timerProvider.isActive) {
          return SizedBox.shrink();
        }

        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final hours = twoDigits(timerProvider.remainingDuration.inHours);
        final minutes = twoDigits(timerProvider.remainingDuration.inMinutes.remainder(60));
        final seconds = twoDigits(timerProvider.remainingDuration.inSeconds.remainder(60));

        return Positioned(
          top: 10,
          right: 10,
          child: Card(
            color: Colors.white.withOpacity(0.9),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    "$hours:$minutes:$seconds",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      timerProvider.stopTimer();
                    },
                    child: Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
