import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable circular countdown timer — the ring + "MM:SS / Time Left"
/// display used on the Recording screen, factored out so it can be
/// reused anywhere else a countdown is needed.
///
/// Manages its own Timer internally. Pausing is controlled from the
/// outside via the [isPaused] parameter (pass a value from your
/// parent's state) rather than an internal button, so this widget
/// stays a simple, controlled display component.
///
/// Example:
/// ```dart
/// TimerWidget(
///   totalSeconds: 60,
///   isPaused: _isPaused,
///   onTick: (secondsLeft) => setState(() => _secondsLeft = secondsLeft),
///   onComplete: _goToAnalysis,
/// )
/// ```
class TimerWidget extends StatefulWidget {
  final int totalSeconds;
  final bool isPaused;
  final ValueChanged<int>? onTick;
  final VoidCallback? onComplete;
  final Color ringColor;
  final Color backgroundColor;
  final Color textColor;
  final double diameter;

  const TimerWidget({
    super.key,
    required this.totalSeconds,
    this.isPaused = false,
    this.onTick,
    this.onComplete,
    this.ringColor = Colors.cyanAccent,
    this.backgroundColor = Colors.white12,
    this.textColor = Colors.white,
    this.diameter = 220,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.totalSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If totalSeconds changes (e.g. parent resets for a new topic),
    // restart the countdown from the new duration.
    if (oldWidget.totalSeconds != widget.totalSeconds) {
      setState(() => _secondsLeft = widget.totalSeconds);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.isPaused) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        widget.onTick?.call(0);
        widget.onComplete?.call();
      } else {
        setState(() => _secondsLeft--);
        widget.onTick?.call(_secondsLeft);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.diameter,
      height: widget.diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.diameter,
            height: widget.diameter,
            child: CircularProgressIndicator(
              value: widget.totalSeconds == 0
                  ? 0
                  : _secondsLeft / widget.totalSeconds,
              strokeWidth: 8,
              backgroundColor: widget.backgroundColor,
              valueColor: AlwaysStoppedAnimation(widget.ringColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formattedTime,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time Left',
                style: TextStyle(color: widget.textColor.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
