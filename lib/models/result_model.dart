// ==========================================
// RESULT MODEL
// The graded outcome of an ExplanationAttempt — either from a real
// AI/local grading pass or the mock fallback.
// ==========================================

class ChallengeResult {
  final int overallScore;
  final int accuracy;
  final int clarity;
  final int confidence;
  final List<String> didWell;
  final List<String> improvements;

  const ChallengeResult({
    required this.overallScore,
    required this.accuracy,
    required this.clarity,
    required this.confidence,
    required this.didWell,
    required this.improvements,
  });
}
