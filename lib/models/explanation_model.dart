import 'question_model.dart';
import '../services/results_store.dart' show AnswerMethod;

// ==========================================
// EXPLANATION MODEL
// What the user actually submitted for a topic: the topic itself,
// the transcript (typed or transcribed from speech), and how it was
// captured. Built by TypeAnswerScreen / RecordingScreen and consumed
// by AnalyzingScreen.
// ==========================================

class ExplanationAttempt {
  final ChallengeTopic topic;
  final String transcript;
  final AnswerMethod method;

  const ExplanationAttempt({
    required this.topic,
    required this.transcript,
    required this.method,
  });
}
