import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/timer_provider.dart';
import '../UI/global_timer_overlay.dart';

class GlobalTimerOverlay extends StatefulWidget {
  @override
  _GlobalTimerOverlayState createState() => _GlobalTimerOverlayState();
}

class _GlobalTimerOverlayState extends State<GlobalTimerOverlay> {
  double _top = 20;
  double _right = 20;

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
          top: _top,
          right: _right,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _top += details.delta.dy;
                _right -= details.delta.dx;
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Color(0xFF12c2e9), Color(0xFFc471ed), Color(0xFFf64f59)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "$hours:$minutes:$seconds",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      timerProvider.stopTimer();
                    },
                    child: Icon(Icons.close, color: Colors.black, size: 24),
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
