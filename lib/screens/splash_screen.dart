import 'package:flutter/material.dart';
import '../main.dart';

/// First screen shown on app launch. Matches the updated design:
/// solid black background, cream logo/text, speech-bubble clock+mic
/// icon, and a cream pill "Get started" button.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color cream = Color(0xFFF5EFDF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Real logo asset, with a graceful fallback to the
              // icon-based logo if Logo.png is missing or corrupted
              // (e.g. "Invalid image data" — the file exists but
              // isn't a valid, readable image).
              Image.asset(
                'assets/images/Logo.png',
                height: 160,
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Logo.png failed to load: $error');
                  return const Icon(Icons.school, size: 100, color: cream);
                },
              ),
              const SizedBox(height: 24),

              const Text(
                '1-Minute\nProfessor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: cream,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Teach to Learn',
                style: TextStyle(color: cream, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(width: 44, height: 2, color: cream.withOpacity(0.6)),

              const SizedBox(height: 64),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cream,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
