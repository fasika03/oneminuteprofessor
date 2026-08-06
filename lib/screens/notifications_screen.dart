import 'package:flutter/material.dart';
import '../services/results_store.dart';

/// One item shown in the notifications list.
class AppNotification {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime time;

  AppNotification({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

/// Notifications screen. Instead of hardcoded/fake entries, this
/// builds real notifications from your actual challenge history:
/// one per completed challenge, plus streak milestone callouts.
/// Opened from the bell icon on the Home screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await ResultsStore.getResults(); // most recent first
    final streak = await ResultsStore.getStreak();

    final List<AppNotification> items = [];

    // One notification per completed challenge.
    for (final r in results) {
      final bool didWell = r.score >= 80;
      items.add(
        AppNotification(
          icon: didWell
              ? Icons.emoji_events_outlined
              : Icons.check_circle_outline,
          color: didWell ? Colors.amber : Colors.blueAccent,
          title: didWell
              ? 'Great job on ${r.subject}!'
              : 'Challenge completed: ${r.subject}',
          subtitle: 'You scored ${r.score}%',
          time: r.completedAt,
        ),
      );
    }

    // Streak milestone notifications, attached to today so they
    // surface near the top alongside recent results.
    if (streak >= 7) {
      items.add(
        AppNotification(
          icon: Icons.local_fire_department,
          color: Colors.deepOrange,
          title: '$streak-day streak! 🔥',
          subtitle: 'Keep it going — don\'t break the chain.',
          time: DateTime.now(),
        ),
      );
    } else if (streak >= 3) {
      items.add(
        AppNotification(
          icon: Icons.local_fire_department_outlined,
          color: Colors.orange,
          title: '$streak-day streak going',
          subtitle: 'A few more days to hit a full week!',
          time: DateTime.now(),
        ),
      );
    }

    items.sort((a, b) => b.time.compareTo(a.time));

    if (!mounted) return;
    setState(() {
      _notifications = items;
      _loading = false;
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No notifications yet — complete a challenge to '
                    'see updates here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: n.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(n.icon, color: n.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTime(n.time),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
