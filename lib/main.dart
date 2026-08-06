import 'package:flutter/material.dart';

// ⚠️ ADJUST THESE IMPORTS/CLASS NAMES to match your actual files.
//   home_screens.dart    -> class HomeScreen
//   second_screens.dart  -> class SecondScreen (currently just a placeholder page)
//   setting_screens.dart -> classes ProgressScreen, ProfileScreen
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sans-Serif',
      ),
      home: const SplashScreen(),
    );
  }
}

/// DashboardScreen owns the bottom navigation.
/// The IndexedStack below is what actually makes tapping
/// "Profile", "Progress", etc. switch screens.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // ⚠️ Order MUST match the BottomNavigationBarItems order below.
  final List<Widget> _screens = const [
    HomeScreen(), // from home_screens.dart
    TopicSelectionScreen(), // from second_screens.dart (Challenge flow entry point)
    ProgressScreen(), // from setting_screens.dart
    ProfileScreen(), // from setting_screens.dart
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_none_outlined),
              label: 'Challenge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
