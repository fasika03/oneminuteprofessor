import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the user provided their answer for a given result — shown as
/// a small icon in the history list so it's clear at a glance.
enum AnswerMethod { voice, typed }

/// One saved result from a completed challenge.
class ChallengeRecord {
  final String subject;
  final int score;
  final DateTime completedAt;
  final String transcript;
  final AnswerMethod method;

  ChallengeRecord({
    required this.subject,
    required this.score,
    required this.completedAt,
    this.transcript = '',
    this.method = AnswerMethod.typed,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'score': score,
    'completedAt': completedAt.toIso8601String(),
    'transcript': transcript,
    'method': method.name,
  };

  factory ChallengeRecord.fromJson(Map<String, dynamic> json) {
    return ChallengeRecord(
      subject: json['subject'] as String,
      score: json['score'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      // Both new fields default safely for records saved before this
      // update existed, so old history entries don't break/crash —
      // they'll just show an empty transcript and a "typed" icon.
      transcript: json['transcript'] as String? ?? '',
      method: AnswerMethod.values.firstWhere(
        (m) => m.name == json['method'],
        orElse: () => AnswerMethod.typed,
      ),
    );
  }
}

/// Simple local persistence for challenge results and streak tracking.
/// Backed by shared_preferences, so results survive app restarts.
/// Swap this out for a real backend/API later without touching the
/// screens that call it — just keep the same method signatures.
class ResultsStore {
  static const _resultsKey = 'challenge_results';
  static const _lastCompletedDateKey = 'last_completed_date';
  static const _streakKey = 'day_streak';
  static const _profileNameKey = 'profile_name';
  static const _profileEmailKey = 'profile_email';

  /// Bumps every time saved data changes (new result, or reset).
  /// Screens can listen to this (e.g. via ValueListenableBuilder or
  /// addListener) to know when to reload, instead of only refreshing
  /// on direct navigation — important because IndexedStack keeps
  /// tabs alive in memory, so a change made on one tab (like
  /// resetting progress from Profile) won't otherwise be picked up
  /// by another tab (like Home) until that tab reloads itself.
  static final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

  /// Call this right after a challenge finishes (in AnalyzingScreen).
  static Future<void> saveResult({
    required String subject,
    required int score,
    String transcript = '',
    AnswerMethod method = AnswerMethod.typed,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final record = ChallengeRecord(
      subject: subject,
      score: score,
      completedAt: DateTime.now(),
      transcript: transcript,
      method: method,
    );

    final existing = prefs.getStringList(_resultsKey) ?? [];
    existing.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_resultsKey, existing);

    await _updateStreak(prefs);
    dataVersion.value++;
  }

  /// Returns all saved results, most recent first.
  static Future<List<ChallengeRecord>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_resultsKey) ?? [];
    final records = raw
        .map(
          (s) =>
              ChallengeRecord.fromJson(jsonDecode(s) as Map<String, dynamic>),
        )
        .toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  /// Returns the N most recent results (defaults to 3, matching the
  /// "Recent Results" card on the Home screen).
  static Future<List<ChallengeRecord>> getRecentResults({int limit = 3}) async {
    final all = await getResults();
    return all.take(limit).toList();
  }

  /// Average score across all saved results, rounded to nearest int.
  /// Returns 0 if there are no results yet.
  static Future<int> getAverageScore() async {
    final all = await getResults();
    if (all.isEmpty) return 0;
    final total = all.fold<int>(0, (sum, r) => sum + r.score);
    return (total / all.length).round();
  }

  /// Total number of distinct topics/subjects completed.
  static Future<int> getTopicsLearnedCount() async {
    final all = await getResults();
    return all.map((r) => r.subject).toSet().length;
  }

  /// Subject with the highest average score, or null if there
  /// are no results yet. Used for Progress screen's "Best Subject".
  static Future<String?> getBestSubject() async {
    final all = await getResults();
    if (all.isEmpty) return null;

    final Map<String, List<int>> scoresBySubject = {};
    for (final r in all) {
      scoresBySubject.putIfAbsent(r.subject, () => []).add(r.score);
    }

    String? bestSubject;
    double bestAvg = -1;
    scoresBySubject.forEach((subject, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestSubject = subject;
      }
    });

    return bestSubject;
  }

  /// Average score per day for the 7 days ending at [anchorDate]
  /// (defaults to today if not given). Days with no completed
  /// challenges show 0. Used to draw the Weekly Score chart on the
  /// Progress screen with real data instead of hardcoded numbers.
  static Future<List<int>> getWeeklyScores({DateTime? anchorDate}) async {
    final all = await getResults();
    final now = anchorDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<int> weekly = [];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final scoresThatDay = all
          .where(
            (r) =>
                r.completedAt.year == day.year &&
                r.completedAt.month == day.month &&
                r.completedAt.day == day.day,
          )
          .map((r) => r.score)
          .toList();

      if (scoresThatDay.isEmpty) {
        weekly.add(0);
      } else {
        final avg =
            scoresThatDay.reduce((a, b) => a + b) / scoresThatDay.length;
        weekly.add(avg.round());
      }
    }
    return weekly;
  }

  /// Average score per 7-day bucket for the 4 weeks ending at
  /// [anchorDate] (defaults to today), for the Progress screen's
  /// "Month" tab. Bucket labels are generated to match in the UI
  /// (e.g. "Wk 1".."Wk 4").
  static Future<List<int>> getMonthlyScores({DateTime? anchorDate}) async {
    final all = await getResults();
    final now = anchorDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<int> buckets = [];
    for (int week = 3; week >= 0; week--) {
      final end = today.subtract(Duration(days: week * 7));
      final start = end.subtract(const Duration(days: 6));
      final scoresInRange = all
          .where((r) {
            final d = DateTime(
              r.completedAt.year,
              r.completedAt.month,
              r.completedAt.day,
            );
            return !d.isBefore(start) && !d.isAfter(end);
          })
          .map((r) => r.score)
          .toList();

      if (scoresInRange.isEmpty) {
        buckets.add(0);
      } else {
        final avg =
            scoresInRange.reduce((a, b) => a + b) / scoresInRange.length;
        buckets.add(avg.round());
      }
    }
    return buckets;
  }

  /// Average score per calendar month for the 6 months ending at
  /// [anchorDate] (defaults to today), for the Progress screen's
  /// "All Time" tab.
  static Future<List<int>> getAllTimeScores({DateTime? anchorDate}) async {
    final all = await getResults();
    final now = anchorDate ?? DateTime.now();

    final List<int> months = [];
    for (int i = 5; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      final scoresInMonth = all
          .where(
            (r) =>
                r.completedAt.year == target.year &&
                r.completedAt.month == target.month,
          )
          .map((r) => r.score)
          .toList();

      if (scoresInMonth.isEmpty) {
        months.add(0);
      } else {
        final avg =
            scoresInMonth.reduce((a, b) => a + b) / scoresInMonth.length;
        months.add(avg.round());
      }
    }
    return months;
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Increments the streak once per calendar day. If a day is missed,
  /// the streak resets to 1 on the next completed challenge.
  static Future<void> _updateStreak(SharedPreferences prefs) async {
    final todayStr = _dateOnly(DateTime.now());
    final lastStr = prefs.getString(_lastCompletedDateKey);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (lastStr == null) {
      await prefs.setInt(_streakKey, 1);
    } else {
      final lastDate = DateTime.parse(lastStr);
      final today = DateTime.parse(todayStr);
      final dayDiff = today.difference(lastDate).inDays;

      if (dayDiff == 0) {
        // already completed one today, streak unchanged
      } else if (dayDiff == 1) {
        await prefs.setInt(_streakKey, currentStreak + 1);
      } else {
        await prefs.setInt(_streakKey, 1);
      }
    }

    await prefs.setString(_lastCompletedDateKey, todayStr);
  }

  static String _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day).toIso8601String();
  }

  /// Useful for testing / a "reset progress" settings option.
  /// Profile display name, shared between the Profile screen and
  /// Home screen (and anywhere else that greets the user by name).
  /// Defaults to 'Alina' if never set, matching the original design.
  static Future<String> getProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileNameKey) ?? 'Alina';
  }

  static Future<void> setProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, name);
    dataVersion.value++;
  }

  static Future<String> getProfileEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileEmailKey) ?? 'alina@example.com';
  }

  static Future<void> setProfileEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileEmailKey, email);
    dataVersion.value++;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resultsKey);
    await prefs.remove(_lastCompletedDateKey);
    await prefs.remove(_streakKey);
    dataVersion.value++;
  }
}
