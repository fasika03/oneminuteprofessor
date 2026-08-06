import 'package:flutter/material.dart';
import '../services/results_store.dart';
import 'second_screens.dart';
import 'results_history_screen.dart';
import 'notifications_screen.dart';

/// Home tab content only (no Scaffold / no BottomNavigationBar here).
/// This widget is meant to be placed inside an IndexedStack in main.dart
/// alongside your other screens (from second_screens.dart / setting_screens.dart)
/// so that switching _selectedIndex actually changes what's on screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  int _avgScore = 0;
  int _topicsLearned = 0;
  List<ChallengeRecord> _recentResults = [];
  String _name = 'Alina';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Reload automatically whenever ResultsStore data changes anywhere
    // in the app (e.g. Reset Progress on the Profile tab), since
    // IndexedStack keeps this screen alive in memory and it otherwise
    // wouldn't know data changed unless it navigated there itself.
    ResultsStore.dataVersion.addListener(_loadData);
  }

  @override
  void dispose() {
    ResultsStore.dataVersion.removeListener(_loadData);
    super.dispose();
  }

  // Pulls real numbers from ResultsStore instead of hardcoded values.
  // Called again in didChangeDependencies-style via the Challenge
  // button's .then(), so returning from a challenge refreshes Home.
  Future<void> _loadData() async {
    final streak = await ResultsStore.getStreak();
    final avg = await ResultsStore.getAverageScore();
    final topics = await ResultsStore.getTopicsLearnedCount();
    final recent = await ResultsStore.getRecentResults(limit: 3);
    final name = await ResultsStore.getProfileName();

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _avgScore = avg;
      _topicsLearned = topics;
      _recentResults = recent;
      _name = name;
      _loading = false;
    });
  }

  Future<void> _openChallengeFlow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopicSelectionScreen()),
    );
    // When the user finishes a challenge and comes back to Home,
    // refresh so the new streak/score/results actually show up.
    _loadData();
  }

  Color _colorForScore(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, $_name ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_outlined,
                      size: 28,
                      color: Colors.black,
                    ),
                    // Small dot shown whenever there's at least one
                    // completed challenge to generate a notification from.
                    if (_recentResults.isNotEmpty)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Streak & Avg Score Cards Row — now real values
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: '🔥',
                  value: '$_streak',
                  label: 'Day streak',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: '⭐',
                  value: '$_avgScore%',
                  label: 'Avg score',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Topics Learned Card — now a real count
          TopicsLearnedCard(topicsCount: '$_topicsLearned'),
          const SizedBox(height: 24),

          // Challenge Call-To-Action Button — now opens the real flow
          ChallengeButton(onPressed: _openChallengeFlow),
          const SizedBox(height: 32),

          // Recent Results Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultsHistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See all',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dynamic Results Table Card — now built from real saved results
          if (_recentResults.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'No challenges completed yet — tap "Start 1-minute challenge" to begin!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _recentResults.length; i++)
                    ResultRow(
                      subject: _recentResults[i].subject,
                      score: '${_recentResults[i].score}%',
                      statusColor: _colorForScore(_recentResults[i].score),
                      isLast: i == _recentResults.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// REUSABLE PRESENTATIONAL STATELESS WIDGETS
// ==========================================

class StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class TopicsLearnedCard extends StatelessWidget {
  final String topicsCount;

  const TopicsLearnedCard({super.key, required this.topicsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Text('📖', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topicsCount,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Topics Learned',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChallengeButton extends StatelessWidget {
  // Now takes a callback instead of hardcoding navigation,
  // so HomeScreen controls exactly what happens on tap.
  final VoidCallback onPressed;

  const ChallengeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 16),
          const Text(
            'Start 1-minute challenge',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String subject;
  final String score;
  final Color statusColor;
  final bool isLast;

  const ResultRow({
    super.key,
    required this.subject,
    required this.score,
    required this.statusColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  Text(
                    score,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }
}
