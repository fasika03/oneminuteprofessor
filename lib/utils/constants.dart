/// App-wide constant values — durations, limits, and defaults used
/// across multiple screens. Centralizing these means changing, say,
/// the challenge time limit only requires editing one number here
/// instead of hunting through second_screens.dart.
class AppConstants {
  AppConstants._();

  // ---- Challenge flow ----
  static const int challengeDurationSeconds = 60;
  static const Duration speechListenDuration = Duration(seconds: 30);
  static const Duration speechPauseDuration = Duration(seconds: 5);
  static const Duration speechRestartDelay = Duration(milliseconds: 300);

  // ---- Text-to-speech ----
  static const String ttsLanguage = 'en-US';
  static const double ttsSpeechRate = 0.45;
  static const double ttsPitch = 1.0;

  // ---- Progress screen ----
  static const int weeklyChartDays = 7;
  static const int monthlyChartWeeks = 4;
  static const int allTimeChartMonths = 6;

  // ---- History ----
  static const int recentResultsLimit = 3;

  // ---- Badge thresholds ----
  static const int streakBadgeThreshold = 7;
  static const int quickLearnerTopicsThreshold = 5;
  static const int sharpShooterScoreThreshold = 90;

  // ---- App info ----
  static const String appName = '1-Minute Professor';
  static const String appTagline = 'Teach to Learn';

  // ---- Default profile ----
  static const String defaultProfileName = 'Alina';
  static const String defaultProfileEmail = 'alina@example.com';

  // ---- SharedPreferences keys ----
  // Centralized here so a typo in a key string (e.g. saving to
  // 'day_streak' but reading from 'daystreak') becomes a compile
  // error instead of a silent bug. Only useful if results_store.dart
  // is updated to reference these instead of its own local consts.
  static const String prefsResultsKey = 'challenge_results';
  static const String prefsLastCompletedDateKey = 'last_completed_date';
  static const String prefsStreakKey = 'day_streak';
  static const String prefsProfileNameKey = 'profile_name';
  static const String prefsProfileEmailKey = 'profile_email';
}
