import 'package:flutter/material.dart';
import '../screens/second_screen.dart';
import '../models/question_model.dart';
import '../models/explanation_model.dart';
import '../models/result_model.dart';

// ==========================================
// APP ROUTES
// Centralized route names + an onGenerateRoute for wiring into
// MaterialApp (MaterialApp(onGenerateRoute: AppRoutes.onGenerateRoute,
// initialRoute: AppRoutes.topicSelection)).
//
// A few of these screens need typed arguments (a ChallengeTopic, an
// ExplanationAttempt, feedback data), so they're passed via
// RouteSettings.arguments and cast back to their real type here —
// this keeps the screens themselves free of any routing knowledge.
//
// Note: the challenge flow's *internal* navigation (topic -> record/
// type -> analyzing -> feedback) still pushes MaterialPageRoute
// directly in second_screen.dart, which is normal for a linear
// in-flow stepper. These named routes are meant for entry points
// into the flow (e.g. from a home screen or bottom nav) — happy to
// convert the internal pushes too if you want everything routed
// through here instead.
// ==========================================
class AppRoutes {
  AppRoutes._();

  static const String topicSelection = '/topic-selection';
  static const String recording = '/recording';
  static const String typeAnswer = '/type-answer';
  static const String analyzing = '/analyzing';
  static const String feedback = '/feedback';
  static const String second = '/second';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case topicSelection:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TopicSelectionScreen(),
        );

      case recording:
        final topic = settings.arguments as ChallengeTopic;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RecordingScreen(topic: topic),
        );

      case typeAnswer:
        final topic = settings.arguments as ChallengeTopic;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TypeAnswerScreen(topic: topic),
        );

      case analyzing:
        final attempt = settings.arguments as ExplanationAttempt;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AnalyzingScreen(attempt: attempt),
        );

      case feedback:
        final args = settings.arguments as FeedbackRouteArgs;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FeedbackScreen(
            topic: args.topic,
            result: args.result,
            usedFallback: args.usedFallback,
            fallbackReason: args.fallbackReason,
          ),
        );

      case second:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SecondScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for "${settings.name}"'),
            ),
          ),
        );
    }
  }
}

/// Bundles FeedbackScreen's four constructor args into one object so
/// it can travel through RouteSettings.arguments as a single value.
class FeedbackRouteArgs {
  final ChallengeTopic topic;
  final ChallengeResult result;
  final bool usedFallback;
  final String? fallbackReason;

  const FeedbackRouteArgs({
    required this.topic,
    required this.result,
    this.usedFallback = false,
    this.fallbackReason,
  });
}
