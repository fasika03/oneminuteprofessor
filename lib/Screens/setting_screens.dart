import 'package:flutter/material.dart';
import '../services/results_store.dart';
import 'splash_screen.dart';

// ==========================================
// PROGRESS TRACKING SCREEN
// ==========================================
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _rangeIndex = 0; // 0 = Week, 1 = Month, 2 = All Time

  final List<String> _ranges = const ['Week', 'Month', 'All Time'];

  // The date the currently-displayed chart is anchored to. Defaults
  // to today; changes when the user picks a date via the calendar
  // icon, shifting the Week/Month/All Time window to end on that date.
  DateTime _anchorDate = DateTime.now();

  int _topicsMastered = 0;
  int _streak = 0;
  String _bestSubject = '-';
  List<int> _chartScores = List.filled(7, 0);
  List<int> _weeklyScores = List.filled(7, 0); // used for badge unlock checks
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh if data changes anywhere else in the app
    // (e.g. finishing a challenge on the Challenge tab, or
    // Reset Progress on the Profile tab).
    ResultsStore.dataVersion.addListener(_loadData);
  }

  @override
  void dispose() {
    ResultsStore.dataVersion.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final topics = await ResultsStore.getTopicsLearnedCount();
    final streak = await ResultsStore.getStreak();
    final bestSubject = await ResultsStore.getBestSubject();
    final weekly = await ResultsStore.getWeeklyScores();
    final chartData = await _loadChartForRange(_rangeIndex);

    if (!mounted) return;
    setState(() {
      _topicsMastered = topics;
      _streak = streak;
      _bestSubject = bestSubject ?? '-';
      _weeklyScores = weekly;
      _chartScores = chartData;
      _loading = false;
    });
  }

  // Loads the correct series depending on which tab (Week/Month/All
  // Time) is selected, anchored to _anchorDate (today by default, or
  // whatever date was picked via the calendar icon).
  Future<List<int>> _loadChartForRange(int rangeIndex) async {
    switch (rangeIndex) {
      case 1:
        return ResultsStore.getMonthlyScores(anchorDate: _anchorDate);
      case 2:
        return ResultsStore.getAllTimeScores(anchorDate: _anchorDate);
      default:
        return ResultsStore.getWeeklyScores(anchorDate: _anchorDate);
    }
  }

  Future<void> _onRangeSelected(int index) async {
    setState(() => _rangeIndex = index);
    final chartData = await _loadChartForRange(index);
    if (!mounted) return;
    setState(() => _chartScores = chartData);
  }

  // Opens a real calendar date picker (day/month/year), and re-anchors
  // whichever tab (Week/Month/All Time) is currently active to end on
  // the picked date, instead of always ending on today.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Keep the picker's theme consistent with the app's
        // black/cream palette instead of Flutter's default blue.
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() => _anchorDate = picked);
    final chartData = await _loadChartForRange(_rangeIndex);
    if (!mounted) return;
    setState(() => _chartScores = chartData);
  }

  // Labels shown under each bar, matching whichever range is active
  // and anchored to _anchorDate.
  List<String> _labelsForRange(int rangeIndex) {
    switch (rangeIndex) {
      case 1:
        return ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
      case 2:
        const monthAbbrev = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return List.generate(6, (i) {
          final target = DateTime(
            _anchorDate.year,
            _anchorDate.month - (5 - i),
            1,
          );
          return monthAbbrev[target.month - 1];
        });
      default:
        const weekdayAbbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return List.generate(7, (i) {
          final daysAgo = 6 - i;
          final day = _anchorDate.subtract(Duration(days: daysAgo));
          return weekdayAbbrev[day.weekday - 1];
        });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Badge unlock rules — adjust thresholds however you like.
  // "Top 10 Global" is left permanently locked since it needs a
  // real leaderboard backend to know your global rank.
  bool _isBadgeUnlocked(String label) {
    switch (label) {
      case '7-Day Streak':
        return _streak >= 7;
      case 'Quick Learner':
        return _topicsMastered >= 5;
      case 'Sharp Shooter':
        return _weeklyScores.any((s) => s >= 90);
      case 'Subject Master':
        return _bestSubject != '-';
      case 'Perfect Week':
        return _weeklyScores.every((s) => s > 0);
      case 'Top 10 Global':
        return false;
      default:
        return false;
    }
  }

  final List<Map<String, dynamic>> _allBadges = const [
    {'icon': Icons.star, 'color': Colors.orange, 'label': 'Perfect Week'},
    {
      'icon': Icons.school,
      'color': Colors.blueAccent,
      'label': 'Quick Learner',
    },
    {
      'icon': Icons.track_changes,
      'color': Colors.deepOrange,
      'label': 'Sharp Shooter',
    },
    {'icon': Icons.bolt, 'color': Colors.green, 'label': '7-Day Streak'},
    {
      'icon': Icons.emoji_events,
      'color': Colors.purple,
      'label': 'Top 10 Global',
    },
    {'icon': Icons.psychology, 'color': Colors.teal, 'label': 'Subject Master'},
  ];

  // Opens a bottom sheet listing every badge, since the badges
  // row on the main screen only shows the first four.
  void _showAllBadges(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Badges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                children: _allBadges.map((badge) {
                  final bool unlocked = _isBadgeUnlocked(badge['label']);
                  return Column(
                    children: [
                      Opacity(
                        opacity: unlocked ? 1.0 : 0.35,
                        child: _BadgeIcon(
                          icon: badge['icon'],
                          color: badge['color'],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: unlocked ? Colors.black87 : Colors.black38,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Row(
                      children: [
                        Text(
                          _isToday(_anchorDate)
                              ? 'Today'
                              : '${_anchorDate.day}/${_anchorDate.month}/${_anchorDate.year}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Range selector (Week / Month / All Time)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: List.generate(_ranges.length, (index) {
                    final bool selected = _rangeIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onRangeSelected(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _ranges[index],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Weekly Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Bar chart — built from plain Flutter widgets (Row/Container)
              // instead of a CustomPainter, so it renders reliably on
              // Chrome/web builds too, not just native emulators.
              Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _WeeklyBarChart(
                  values: _chartScores,
                  labels: _labelsForRange(_rangeIndex),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.menu_book_outlined,
                      label: 'Topics Mastered',
                      value: '$_topicsMastered',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      emoji: '🔥',
                      label: 'Current Streak',
                      value: '$_streak Days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.star_outline,
                      label: 'Best Subject',
                      value: _bestSubject,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Badges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAllBadges(context),
                    child: const Text(
                      'See all',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: _allBadges.take(4).map((badge) {
                  final bool unlocked = _isBadgeUnlocked(badge['label']);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Opacity(
                      opacity: unlocked ? 1.0 : 0.35,
                      child: _BadgeIcon(
                        icon: badge['icon'],
                        color: badge['color'],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData? icon;
  final String? emoji; // e.g. '🔥' — takes priority over icon if both given
  final String label;
  final String value;

  const _InfoTile({
    this.icon,
    this.emoji,
    required this.label,
    required this.value,
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
      child: Row(
        children: [
          emoji != null
              ? Text(emoji!, style: const TextStyle(fontSize: 20))
              : Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _BadgeIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}

/// Weekly Score bar chart. Built from plain Row/Container widgets
/// (no CustomPainter) so it renders reliably in Chrome/web builds,
/// which is what this project is running in since the emulator
/// isn't available. Each bar's height is proportional to that
/// day's average score out of 100; days with no data show as
/// a faint minimum-height bar instead of disappearing entirely.
class _WeeklyBarChart extends StatelessWidget {
  final List<int> values; // values, oldest to newest
  final List<String> labels; // must be same length as values

  const _WeeklyBarChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 120;
    const double minBarHeight = 4;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(values.length, (i) {
              final score = values[i];
              final barHeight = score <= 0
                  ? minBarHeight
                  : (score / 100) * maxBarHeight;
              final bool hasData = score > 0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasData)
                        Text(
                          '$score',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: hasData
                              ? Colors.blueAccent
                              : Colors.grey.shade200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(values.length, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ==========================================
// PROFILE SCREEN
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Alina';
  String _email = 'alina@example.com';
  int _streak = 0;
  int _avgScore = 0;
  bool _loading = true;

  bool _pushNotifications = true;
  bool _emailDigest = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Auto-refresh if data changes anywhere else in the app (e.g.
    // completing a challenge on the Challenge tab, or Reset Progress
    // right here in Profile), since IndexedStack keeps this screen
    // alive in memory rather than rebuilding it from scratch.
    ResultsStore.dataVersion.addListener(_loadProfile);
  }

  @override
  void dispose() {
    ResultsStore.dataVersion.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final name = await ResultsStore.getProfileName();
    final email = await ResultsStore.getProfileEmail();
    final streak = await ResultsStore.getStreak();
    final avgScore = await ResultsStore.getAverageScore();
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
      _streak = streak;
      _avgScore = avgScore;
      _loading = false;
    });
  }

  // Opens a dialog with editable text fields, pre-filled with
  // the current name/email. On Save, persists via ResultsStore so
  // Home (and anywhere else showing the name) picks up the change too.
  // Standard-enough email format check: something@something.tld
  // Not a full RFC 5322 validator (those are notoriously overkill),
  // but catches the common mistakes — missing @, missing domain,
  // no dot in the domain, spaces, etc.
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  Future<void> _openEditProfileDialog() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final email = emailController.text.trim();
            final bool emailValid =
                email.isEmpty || _emailPattern.hasMatch(email);

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: emailValid
                          ? null
                          : 'Enter a valid email, e.g. name@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  // Disabled while the email is non-empty but invalid,
                  // so a malformed address can't be saved at all.
                  onPressed: !emailValid
                      ? null
                      : () {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();
                          Navigator.pop(context, {
                            'name': newName.isEmpty ? _name : newName,
                            'email': newEmail.isEmpty ? _email : newEmail,
                          });
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // result is null if the user tapped Cancel or dismissed the dialog.
    if (result != null) {
      await ResultsStore.setProfileName(result['name']!);
      await ResultsStore.setProfileEmail(result['email']!);
      if (!mounted) return;
      setState(() {
        _name = result['name']!;
        _email = result['email']!;
      });
    }
  }

  // Notifications: a dialog with real toggle switches.
  // Uses StatefulBuilder so the switches update immediately inside
  // the dialog, then setState() on this screen persists the choice.
  Future<void> _openNotificationsDialog() async {
    bool tempPush = _pushNotifications;
    bool tempEmail = _emailDigest;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(color: Colors.black),
                    ),
                    value: tempPush,
                    activeColor: Colors.black,
                    onChanged: (value) =>
                        setDialogState(() => tempPush = value),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Email Digest',
                      style: TextStyle(color: Colors.black),
                    ),
                    value: tempEmail,
                    activeColor: Colors.black,
                    onChanged: (value) =>
                        setDialogState(() => tempEmail = value),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _pushNotifications = tempPush;
                      _emailDigest = tempEmail;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openPrivacyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _SimpleInfoScreen(
          title: 'Privacy & Security',
          body:
              'Your data is stored securely and never shared with third '
              'parties without your consent. You can request account '
              'deletion at any time from this screen in a future update.',
        ),
      ),
    );
  }

  void _openHelpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _SimpleInfoScreen(
          title: 'Help & Support',
          body:
              'Need help? Reach us at support@oneminuteprofessor.app or '
              'check the FAQ section for answers to common questions about '
              'streaks, scoring, and challenges.',
        ),
      ),
    );
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Reset Progress',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'This will permanently delete your streak, average score, '
            'topics learned, and all saved challenge results. This '
            'cannot be undone.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ResultsStore.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Progress has been reset')));
    }
  }

  Future<void> _confirmLogOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Log Out', style: TextStyle(color: Colors.black)),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Hook this up to your real auth/sign-out logic when you add
      // real accounts. For now, this returns to the Splash screen
      // and clears the entire navigation stack (pushAndRemoveUntil
      // with (route) => false), so tapping back afterward can't pop
      // back into the logged-in app.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: Color(0xFFF2F2F2),
                      child: Icon(
                        Icons.person,
                        size: 44,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(_email, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _ProfileStat(label: 'Day Streak', value: '$_streak'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProfileStat(
                      label: 'Avg Score',
                      value: '$_avgScore%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              _SettingsRow(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: _openEditProfileDialog,
              ),
              _SettingsRow(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onTap: _openNotificationsDialog,
              ),
              _SettingsRow(
                icon: Icons.lock_outline,
                label: 'Privacy & Security',
                onTap: _openPrivacyScreen,
              ),
              _SettingsRow(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: _openHelpScreen,
              ),
              _SettingsRow(
                icon: Icons.restart_alt,
                label: 'Reset Progress',
                onTap: _confirmResetProgress,
                isDestructive: true,
              ),
              _SettingsRow(
                icon: Icons.logout,
                label: 'Log Out',
                onTap: _confirmLogOut,
                isDestructive: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

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
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// Simple reusable placeholder page used by Privacy & Security and
// Help & Support. Replace the body text with real content/screens later.
class _SimpleInfoScreen extends StatelessWidget {
  final String title;
  final String body;

  const _SimpleInfoScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          body,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive ? Colors.redAccent : Colors.black87;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, color: color)),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
