import 'package:flutter/material.dart';

/// Reusable loading indicator with an optional message underneath —
/// use this instead of a bare CircularProgressIndicator so every
/// "please wait" moment in the app looks the same (e.g. loading
/// Home's stats, waiting for AI grading, loading history).
///
/// Example:
/// ```dart
/// if (_loading) return const LoadingWidget();
///
/// if (_loading) {
///   return const LoadingWidget(message: 'Analyzing your explanation...');
/// }
/// ```
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color = Colors.deepPurple,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen version — wraps LoadingWidget in a Scaffold with the
/// app's standard white background, for screens that load before
/// they have anything else to show (e.g. ProfileScreen, ProgressScreen
/// while fetching data on initState).
///
/// Example:
/// ```dart
/// if (_loading) {
///   return const LoadingScaffold(message: 'Loading your progress...');
/// }
/// ```
class LoadingScaffold extends StatelessWidget {
  final String? message;

  const LoadingScaffold({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingWidget(message: message),
    );
  }
}
