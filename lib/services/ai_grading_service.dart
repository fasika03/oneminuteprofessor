import 'dart:math';

// ==========================================
// RESULT MODEL RETURNED BY gradeExplanation
// (unchanged — same shape the rest of the app expects)
// ==========================================
class GradedExplanation {
  final int overallScore;
  final int accuracy;
  final int clarity;
  final int confidence;
  final List<String> didWell;
  final List<String> improvements;

  const GradedExplanation({
    required this.overallScore,
    required this.accuracy,
    required this.clarity,
    required this.confidence,
    required this.didWell,
    required this.improvements,
  });
}

// ==========================================
// AI GRADING SERVICE — LOCAL / OFFLINE VERSION
// No API key, no network call. Scores are computed from the
// transcript text itself using simple heuristics:
//   - Accuracy   -> how many topic-relevant keywords show up
//   - Clarity    -> sentence structure + filler-word density
//   - Confidence -> hedging language vs. assertive language
//
// This is intentionally simple and transparent (no black box),
// and keeps the exact same public API (`gradeExplanation`,
// `generateExampleAnswer`) so RecordingScreen/AnalyzingScreen
// don't need any changes.
// ==========================================
class AiGradingService {
  static final Random _rand = Random();

  // Common filler words that hurt clarity when overused.
  static const List<String> _fillerWords = [
    'um', 'uh', 'like', 'you know', 'kind of', 'sort of', 'basically',
    'literally', 'actually', 'i mean',
  ];

  // Words/phrases that signal the speaker is unsure of themselves.
  static const List<String> _hedgingWords = [
    'maybe', 'i think', 'i guess', 'probably', 'not sure', 'kind of',
    'sort of', 'i don\'t know', 'might be', 'could be wrong',
  ];

  // Words/phrases that signal confident, assertive delivery.
  static const List<String> _assertiveWords = [
    'definitely', 'clearly', 'exactly', 'specifically', 'because',
    'therefore', 'for example', 'this means', 'in other words',
  ];

  // Generic filler stopwords stripped out when extracting "topic
  // keywords" from a question-style title like "What is Gravity?".
  static const List<String> _stopWords = [
    'what', 'is', 'was', 'were', 'are', 'the', 'a', 'an', 'of', 'in',
    'to', 'and', 'caused', 'do', 'does', 'how',
  ];

  // ==========================================
  // GRADE STUDENT EXPLANATION (local, synchronous logic wrapped
  // in Future so callers using `await` keep working unchanged)
  // ==========================================
  static Future<GradedExplanation> gradeExplanation({
    required String topic,
    required String transcript,
  }) async {
    final cleanTranscript = transcript.trim();
    if (cleanTranscript.isEmpty) {
      throw Exception('No transcript to grade — nothing was recorded.');
    }

    final lowerTranscript = cleanTranscript.toLowerCase();
    final words = _words(lowerTranscript);
    final sentences = _splitSentences(cleanTranscript);

    final accuracy = _scoreAccuracy(topic, lowerTranscript, words);
    final clarity = _scoreClarity(lowerTranscript, words, sentences);
    final confidence = _scoreConfidence(lowerTranscript, words);
    final overall = ((accuracy + clarity + confidence) / 3).round();

    final didWell = <String>[];
    final improvements = <String>[];

    // --- Accuracy feedback ---
    if (accuracy >= 75) {
      didWell.add('Covered the key ideas of the topic');
    } else {
      improvements.add('Mention more of the core concept\'s key terms');
    }

    // --- Clarity feedback ---
    if (words.length < 25) {
      improvements.add('Explanation is quite short — add more detail');
    } else if (words.length > 25 && sentences.length >= 2) {
      didWell.add('Explained with reasonable depth');
    }

    final fillerCount = _countOccurrences(lowerTranscript, _fillerWords);
    if (fillerCount > 3) {
      improvements.add('Reduce filler words (um, like, basically...)');
    } else {
      didWell.add('Spoke without too many filler words');
    }

    if (sentences.length >= 3) {
      didWell.add('Organized explanation into multiple points');
    } else {
      improvements.add('Break the explanation into more sentences');
    }

    // --- Confidence feedback ---
    final hedgeCount = _countOccurrences(lowerTranscript, _hedgingWords);
    final assertiveCount = _countOccurrences(lowerTranscript, _assertiveWords);
    if (assertiveCount > hedgeCount) {
      didWell.add('Sounded confident and direct');
    } else if (hedgeCount > 0) {
      improvements.add('Use fewer hedging phrases like "maybe" or "I think"');
    }

    if (cleanTranscript.contains('example') ||
        cleanTranscript.contains('for instance') ||
        cleanTranscript.contains('like when')) {
      didWell.add('Used a concrete example');
    } else {
      improvements.add('Add a concrete example to illustrate the idea');
    }

    // Keep each list within the 2-4 range the rest of the app expects.
    _trimList(didWell, min: 2, max: 4, fallback: 'Attempted the explanation');
    _trimList(
      improvements,
      min: 2,
      max: 4,
      fallback: 'Review the topic and try explaining it again',
    );

    return GradedExplanation(
      overallScore: overall,
      accuracy: accuracy,
      clarity: clarity,
      confidence: confidence,
      didWell: didWell,
      improvements: improvements,
    );
  }

  // ==========================================
  // GENERATE EXAMPLE ANSWER — local canned template instead of an
  // AI-written one, built from the topic title itself. Simple and
  // predictable, no network call.
  // ==========================================
  static Future<String> generateExampleAnswer({required String topic}) async {
    final subject = _stripQuestionPrefix(topic);
    return 'To explain "$subject" simply: start with a one-sentence '
        'definition in plain language, then give a real-world example '
        'someone without background knowledge could relate to. Avoid '
        'jargon — if you must use a technical term, explain it right '
        'after you say it. Finish by connecting it back to something '
        'the listener already knows, so the idea sticks.';
  }

  // ==========================================
  // SCORING HELPERS
  // ==========================================

  static int _scoreAccuracy(
    String topic,
    String lowerTranscript,
    List<String> words,
  ) {
    final keywords = _topicKeywords(topic);
    if (keywords.isEmpty) {
      // No usable keywords (e.g. very short custom topic) — fall back
      // to a length-based estimate so the score isn't arbitrary.
      return _clamp(50 + min(words.length, 40));
    }

    var hits = 0;
    for (final kw in keywords) {
      if (lowerTranscript.contains(kw)) hits++;
    }
    final coverage = hits / keywords.length; // 0.0 - 1.0
    final base = 40 + (coverage * 55).round(); // 40-95
    return _clamp(base);
  }

  static int _scoreClarity(
    String lowerTranscript,
    List<String> words,
    List<String> sentences,
  ) {
    var score = 60;

    // Reward reasonable length.
    if (words.length >= 20) score += 10;
    if (words.length >= 40) score += 5;
    if (words.length < 10) score -= 20;

    // Reward multiple sentences (structure).
    if (sentences.length >= 2) score += 8;
    if (sentences.length >= 4) score += 7;

    // Penalize filler-word density.
    final fillerCount = _countOccurrences(lowerTranscript, _fillerWords);
    score -= min(fillerCount * 4, 20);

    // Penalize run-on single-sentence answers.
    final avgWordsPerSentence =
        sentences.isEmpty ? words.length.toDouble() : words.length / sentences.length;
    if (avgWordsPerSentence > 35) score -= 10;

    return _clamp(score);
  }

  static int _scoreConfidence(String lowerTranscript, List<String> words) {
    var score = 70;

    final hedgeCount = _countOccurrences(lowerTranscript, _hedgingWords);
    final assertiveCount = _countOccurrences(lowerTranscript, _assertiveWords);

    score += assertiveCount * 5;
    score -= hedgeCount * 6;

    // Very short answers read as low-confidence by default.
    if (words.length < 10) score -= 15;

    return _clamp(score);
  }

  // ==========================================
  // TEXT UTILITIES
  // ==========================================

  static List<String> _topicKeywords(String topic) {
    final cleaned = topic.replaceAll('?', '').toLowerCase();
    final rawWords = cleaned.split(RegExp(r'\s+'));
    return rawWords
        .where((w) => w.isNotEmpty && !_stopWords.contains(w) && w.length > 2)
        .toSet()
        .toList();
  }

  static String _stripQuestionPrefix(String title) {
    String result = title.trim();
    const prefixes = [
      'What is ',
      'What was ',
      'What were ',
      'What caused ',
      'What are ',
    ];
    for (final prefix in prefixes) {
      if (result.startsWith(prefix)) {
        result = result.substring(prefix.length);
        break;
      }
    }
    return result.replaceAll('?', '').trim();
  }

  static List<String> _words(String text) {
    return text
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  static List<String> _splitSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static int _countOccurrences(String text, List<String> phrases) {
    var count = 0;
    for (final phrase in phrases) {
      final matches = RegExp(RegExp.escape(phrase)).allMatches(text);
      count += matches.length;
    }
    return count;
  }

  static int _clamp(num value) => value.round().clamp(0, 100);

  static void _trimList(
    List<String> list, {
    required int min,
    required int max,
    required String fallback,
  }) {
    // Remove duplicates while preserving order.
    final deduped = list.toSet().toList();
    list
      ..clear()
      ..addAll(deduped);

    while (list.length < min) {
      list.add(fallback);
    }
    if (list.length > max) {
      list.removeRange(max, list.length);
    }
  }
}