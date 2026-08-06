import 'package:flutter/material.dart';
import '../services/results_store.dart';

/// Shows every completed challenge, most recent first.
/// Opened from Home's "See all" link next to Recent Results.
/// Tap any entry to see the full answer text (what you typed or
/// what your voice was transcribed as) plus its AI feedback summary.
class ResultsHistoryScreen extends StatefulWidget {
  const ResultsHistoryScreen({super.key});

  @override
  State<ResultsHistoryScreen> createState() => _ResultsHistoryScreenState();
}

class _ResultsHistoryScreenState extends State<ResultsHistoryScreen> {
  List<ChallengeRecord> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ResultsStore.getResults();
    if (!mounted) return;
    setState(() {
      _results = all;
      _loading = false;
    });
  }

  Color _colorForScore(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.amber;
    return Colors.redAccent;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';

    const months = [
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
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('All Results'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _results.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No challenges completed yet.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final r = _results[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultDetailScreen(record: r),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          // Icon showing whether this was answered
                          // by voice or by typing.
                          Icon(
                            r.method == AnswerMethod.voice
                                ? Icons.mic
                                : Icons.keyboard,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.subject,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(r.completedAt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${r.score}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _colorForScore(r.score),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Full detail view for one past result — shows the complete answer
/// text (what was typed or what the voice transcript captured),
/// since the list view only has room for a preview line.
class ResultDetailScreen extends StatelessWidget {
  final ChallengeRecord record;

  const ResultDetailScreen({super.key, required this.record});

  Color _colorForScore(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.amber;
    return Colors.redAccent;
  }

  String _formatFullDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour12:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Result Detail'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    record.method == AnswerMethod.voice
                        ? Icons.mic
                        : Icons.keyboard,
                    size: 20,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.method == AnswerMethod.voice
                        ? 'Answered by voice'
                        : 'Answered by typing',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                record.subject,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatFullDate(record.completedAt),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _colorForScore(record.score).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${record.score}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _colorForScore(record.score),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Score out of 100',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Your Answer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  record.transcript.isEmpty
                      ? '(No answer text was saved for this older entry.)'
                      : record.transcript,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: record.transcript.isEmpty
                        ? Colors.grey.shade500
                        : Colors.black87,
                    fontStyle: record.transcript.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
