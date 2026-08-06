import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/results_store.dart';
import '../services/ai_grading_service.dart';

// ==========================================
// KEEPING YOUR ORIGINAL PLACEHOLDER
// (not used in the nav anymore, but left here
// in case something else still references it)
// ==========================================
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: const Center(
        child: Text(
          'Welcome to Second Screen 🎉',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// ==========================================
// SIMPLE TOPIC MODEL + BANK
// Swap _topicBank for a real API call whenever you have a backend.
// ==========================================
class ChallengeTopic {
  final String title;
  final String difficulty;

  const ChallengeTopic({required this.title, required this.difficulty});
}

const List<ChallengeTopic> _topicBank = [
  // Science
  ChallengeTopic(title: 'What is Photosynthesis?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Water?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Newton\'s Third Law?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Gravity?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is DNA?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is an Ecosystem?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is the Water Cycle?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Natural Selection?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Quantum Entanglement?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is the Theory of Relativity?',
    difficulty: 'Hard',
  ),
  ChallengeTopic(title: 'What is a Black Hole?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is CRISPR Gene Editing?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is the Greenhouse Effect?', difficulty: 'Medium'),

  // Technology / Computer Science
  ChallengeTopic(title: 'What is Blockchain?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Machine Learning?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Database Index?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is an API?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Cloud Computing?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Encryption?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Neural Network?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is Object-Oriented Programming?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is a Recursive Function?', difficulty: 'Hard'),
  ChallengeTopic(title: 'What is the Internet of Things?', difficulty: 'Easy'),

  // Math
  ChallengeTopic(title: 'What is the Pythagorean Theorem?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is a Derivative?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Compound Interest?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is a Prime Number?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Probability?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Standard Deviation?', difficulty: 'Hard'),

  // History / Social Studies
  ChallengeTopic(title: 'What caused World War I?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What was the Renaissance?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Democracy?', difficulty: 'Easy'),
  ChallengeTopic(
    title: 'What was the Industrial Revolution?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is Inflation?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Supply and Demand?', difficulty: 'Easy'),

  // General / Everyday concepts
  ChallengeTopic(
    title: 'What is Emotional Intelligence?',
    difficulty: 'Medium',
  ),
  ChallengeTopic(title: 'What is Compound Growth?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is a Placebo Effect?', difficulty: 'Medium'),
  ChallengeTopic(title: 'What is Time Zones?', difficulty: 'Easy'),
  ChallengeTopic(title: 'What is Cognitive Bias?', difficulty: 'Hard'),
  ChallengeTopic(
    title: 'What is Sustainable Development?',
    difficulty: 'Medium',
  ),
];

// ==========================================
// 1. TOPIC SELECTION SCREEN (entry point for the Challenge tab)
// ==========================================
class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  late ChallengeTopic _topic;

  @override
  void initState() {
    super.initState();
    _topic = _randomTopic();
  }

  ChallengeTopic _randomTopic() {
    return _topicBank[Random().nextInt(_topicBank.length)];
  }

  void _shuffleTopic() {
    setState(() {
      _topic = _randomTopic();
    });
  }

  // Lets the user type their own question instead of picking from
  // the random topic bank. Difficulty defaults to "Custom" since
  // there's no automatic way to judge difficulty of a free-typed
  // question.
  Future<void> _openCustomTopicDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Enter Your Own Topic',
            style: TextStyle(color: Colors.black),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'e.g. What is quantum entanglement?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = controller.text.trim();
                Navigator.pop(context, text.isEmpty ? null : text);
              },
              child: const Text('Use This Topic'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _topic = ChallengeTopic(title: result, difficulty: 'Custom');
      });
    }
  }

  void _startExplaining() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How do you want to explain?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // close the sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordingScreen(topic: _topic),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.mic),
                    label: const Text('Speak It'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // close the sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TypeAnswerScreen(topic: _topic),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Type It'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Color get _difficultyColor {
    switch (_topic.difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Hard':
        return Colors.redAccent;
      case 'Custom':
        return Colors.blueAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    size: 36,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Today's Topic",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: Colors.black26,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _topic.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Difficulty: ',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        Text(
                          _topic.difficulty,
                          style: TextStyle(
                            color: _difficultyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.bar_chart,
                          size: 18,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Center(
                child: TextButton.icon(
                  onPressed: _openCustomTopicDialog,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Enter your own topic'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _shuffleTopic,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Topic'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startExplaining,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Start Explaining'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. TYPE YOUR ANSWER SCREEN
// Replaces the old voice-recording screen. No microphone, no
// text-to-speech, no countdown — just a text box where the user
// types their explanation, which then goes to the same AI grading
// flow as before (AnalyzingScreen -> FeedbackScreen).
// ==========================================
class TypeAnswerScreen extends StatefulWidget {
  final ChallengeTopic topic;

  const TypeAnswerScreen({super.key, required this.topic});

  @override
  State<TypeAnswerScreen> createState() => _TypeAnswerScreenState();
}

class _TypeAnswerScreenState extends State<TypeAnswerScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzingScreen(
          topic: widget.topic,
          transcript: answer,
          method: AnswerMethod.typed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Explain the Topic'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Topic',
                style: TextStyle(color: Colors.deepPurple, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                widget.topic.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Type your explanation below, as if teaching someone '
                'this topic for the first time.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Start typing your explanation...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Submit for Grading'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2b. RECORDING SCREEN (voice option, 60 second countdown)
// Restored alongside TypeAnswerScreen so the user can choose either
// method from the bottom sheet in _startExplaining().
// ==========================================
class RecordingScreen extends StatefulWidget {
  final ChallengeTopic topic;

  const RecordingScreen({super.key, required this.topic});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  static const int _totalSeconds = 60;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  bool _isPaused = false;
  bool _usedManualEntry = false; // true if "Type your answer instead" was used

  // Real speech-to-text capture. On Chrome/web this uses the
  // browser's built-in Web Speech API (no server needed); on a real
  // device it uses the platform's native speech recognizer. The
  // browser/OS will prompt for microphone permission the first time
  // this runs.
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  String _transcript = '';
  String _liveInterimText = '';
  String? _speechInitError;
  String _liveStatus = 'starting…';
  int _restartCount = 0;
  double _lastSoundLevel = 0;

  // Text-to-speech: reads the topic question aloud before recording
  // starts, so the user hears it instead of only reading it.
  final FlutterTts _tts = FlutterTts();
  bool _isSpeakingTopic = true;

  @override
  void initState() {
    super.initState();
    _speakTopicThenBegin();
  }

  Future<void> _speakTopicThenBegin() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(widget.topic.title);
    } catch (e) {
      debugPrint('TTS failed, continuing without reading topic aloud: $e');
    }

    if (!mounted) return;
    setState(() => _isSpeakingTopic = false);

    _startTimer();
    _initSpeech();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _goToAnalysis();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          if (mounted) {
            setState(() => _liveStatus = 'error: ${error.errorMsg}');
          }
          _restartListeningIfStillRecording();
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (mounted) {
            setState(() => _liveStatus = status);
          }
          if (status == 'done' || status == 'notListening') {
            _restartListeningIfStillRecording();
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
        if (!available) {
          _speechInitError =
              'initialize() returned false — the device '
              'reports no speech recognizer is available. This usually '
              'means the Google app (or Google Speech Services) isn\'t '
              'installed/enabled/updated on this device.';
        }
      });
    } catch (e) {
      debugPrint('Speech init exception: $e');
      if (mounted) {
        setState(() {
          _speechAvailable = false;
          _speechInitError = 'Exception during initialize(): $e';
        });
      }
      return;
    }

    if (_speechAvailable) {
      _startListening();
    }
  }

  void _restartListeningIfStillRecording() {
    if (!mounted || _isPaused || _secondsLeft <= 0) return;
    setState(() => _restartCount++);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _isPaused || _secondsLeft <= 0) return;
      _startListening();
    });
  }

  void _startListening() {
    if (!_speechAvailable || _isPaused) return;
    _speech.listen(
      onResult: (result) {
        setState(() {
          if (result.finalResult) {
            final newWords = result.recognizedWords.trim();
            if (newWords.isNotEmpty) {
              _transcript = _transcript.isEmpty
                  ? newWords
                  : '$_transcript $newWords';
            }
          } else {
            _liveInterimText = result.recognizedWords;
          }
        });
      },
      onSoundLevelChange: (level) {
        if (mounted) {
          setState(() => _lastSoundLevel = level);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _speech.stop();
    } else {
      _startListening();
    }
  }

  void _stopEarly() {
    _timer?.cancel();
    _speech.stop();
    _goToAnalysis();
  }

  // Manual fallback: lets the user type (or fix up) what they said,
  // in case voice capture doesn't work reliably on this browser/
  // device. Pre-fills with whatever was captured by voice so far.
  Future<void> _openManualTranscriptDialog() async {
    final controller = TextEditingController(text: _transcript);
    final focusNode = FocusNode();

    void submit(BuildContext dialogContext) {
      final value = controller.text.trim();
      debugPrint('Manual transcript submit tapped, value: "$value"');
      focusNode.unfocus();
      Navigator.of(dialogContext).pop(value);
    }

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Type Your Answer',
            style: TextStyle(color: Colors.black),
          ),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            maxLines: 6,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Type what you explained about this topic...',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(dialogContext),
          ),
          actions: [
            TextButton(
              onPressed: () {
                focusNode.unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => submit(dialogContext),
              child: const Text('Use This'),
            ),
          ],
        );
      },
    );

    focusNode.dispose();

    if (result != null && mounted) {
      setState(() {
        _transcript = result;
        _usedManualEntry = true;
      });
    }
  }

  void _goToAnalysis() {
    if (!mounted) return;
    _speech.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzingScreen(
          topic: widget.topic,
          transcript: _transcript,
          method: _usedManualEntry ? AnswerMethod.typed : AnswerMethod.voice,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    '${_totalSeconds}s',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Topic',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                widget.topic.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_isSpeakingTopic)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.volume_up,
                        color: Colors.cyanAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reading topic aloud…',
                        style: TextStyle(
                          color: Colors.cyanAccent.shade100,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),

              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: _secondsLeft / _totalSeconds,
                        strokeWidth: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.cyanAccent,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Time Left',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              if (!_speechAvailable)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    _speechInitError ??
                        'Speech recognition unavailable on this browser/device.\n'
                            'Grading will fail without a transcript.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent.shade100,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Builder(
                      builder: (context) {
                        final combined = [
                          _transcript,
                          _liveInterimText,
                        ].where((s) => s.isNotEmpty).join(' ');
                        return Text(
                          combined.isEmpty ? 'Listening...' : combined,
                          style: TextStyle(
                            color: combined.isEmpty
                                ? Colors.white38
                                : Colors.white70,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              if (_speechAvailable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'status: $_liveStatus  •  restarts: $_restartCount  •  '
                    'mic level: ${_lastSoundLevel.toStringAsFixed(1)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.amber, fontSize: 11),
                  ),
                ),

              SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(24, (i) {
                    final h =
                        6.0 +
                        (i % 5) * 5.0 +
                        (_isPaused ? 0 : (i.isEven ? 6 : 0));
                    return Container(
                      width: 3,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 8),
              const Text(
                'Speak like a teacher!',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _togglePause,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _stopEarly,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _openManualTranscriptDialog,
                icon: const Icon(
                  Icons.keyboard,
                  size: 18,
                  color: Colors.white70,
                ),
                label: const Text(
                  'Type your answer instead',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. AI ANALYSIS SCREEN (loading state)
// Now calls the real AiGradingService with the actual transcript.
// Falls back to mock grading (with a visible note on the Feedback
// screen) if the API call fails — e.g. no API key set, no internet,
// or nothing was transcribed — so the app never gets stuck here.
// ==========================================
class AnalyzingScreen extends StatefulWidget {
  final ChallengeTopic topic;
  final String transcript;
  final AnswerMethod method;

  const AnalyzingScreen({
    super.key,
    required this.topic,
    required this.transcript,
    this.method = AnswerMethod.typed,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    ChallengeResult result;
    bool usedFallback = false;
    String? fallbackReason;

    try {
      final graded = await AiGradingService.gradeExplanation(
        topic: widget.topic.title,
        transcript: widget.transcript,
      );
      result = ChallengeResult(
        overallScore: graded.overallScore,
        accuracy: graded.accuracy,
        clarity: graded.clarity,
        confidence: graded.confidence,
        didWell: graded.didWell,
        improvements: graded.improvements,
      );
    } catch (e) {
      // Real grading failed — fall back to a mock result so the user
      // still gets a Feedback screen instead of a stuck loading state,
      // but tell them clearly it wasn't a real grade.
      debugPrint('AI grading failed, using fallback: $e');
      usedFallback = true;
      fallbackReason = e.toString();
      result = _mockGradeResult();
    }

    if (!mounted) return;

    // Only persist real, AI-graded results — a placeholder/fallback
    // score (random mock numbers, used when grading fails) would
    // otherwise quietly pollute Home's streak/avg score, Progress's
    // charts and badges, and the results history with fake data
    // that doesn't reflect anything the user actually did well or
    // poorly at.
    if (!usedFallback) {
      await ResultsStore.saveResult(
        subject: _subjectFromTopic(widget.topic.title),
        score: result.overallScore,
        transcript: widget.transcript,
        method: widget.method,
      );
    } else {
      debugPrint(
        'Skipping ResultsStore.saveResult — fallback/placeholder score, not real.',
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          topic: widget.topic,
          result: result,
          usedFallback: usedFallback,
          fallbackReason: fallbackReason,
        ),
      ),
    );
  }

  // Turns a question-style topic title into a short subject label,
  // e.g. "What is Blockchain?" -> "Blockchain", for display in
  // Home's Recent Results list.
  // Strips common question-starter phrasing so Recent Results shows
  // a clean subject name regardless of how the topic is phrased
  // (e.g. "What is X?", "What caused X?", "What was X?" all become "X").
  String _subjectFromTopic(String title) {
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

  ChallengeResult _mockGradeResult() {
    final rand = Random();
    final accuracy = 70 + rand.nextInt(26); // 70-95
    final clarity = 65 + rand.nextInt(31); // 65-95
    final confidence = 70 + rand.nextInt(26); // 70-95
    final overall = ((accuracy + clarity + confidence) / 3).round();

    return ChallengeResult(
      overallScore: overall,
      accuracy: accuracy,
      clarity: clarity,
      confidence: confidence,
      didWell: const ['Clear definition', 'Good examples'],
      improvements: const ['Missed key concept', 'Needed more detail'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  size: 56,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 20),
              const Text(
                'Analyzing Your\nExplanation...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI is listening and evaluating\naccuracy, clarity and more.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// RESULT MODEL
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

// ==========================================
// 4. FEEDBACK & SCORE SCREEN
// ==========================================
class FeedbackScreen extends StatelessWidget {
  final ChallengeTopic topic;
  final ChallengeResult result;
  final bool usedFallback;
  final String? fallbackReason;

  const FeedbackScreen({
    super.key,
    required this.topic,
    required this.result,
    this.usedFallback = false,
    this.fallbackReason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                  const Expanded(
                    child: Text(
                      'Your Score',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              if (usedFallback)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a placeholder score — real AI grading '
                          'wasn\'t available (${fallbackReason ?? "unknown error"}). '
                          'This attempt was not saved to your history or stats.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: result.overallScore / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.deepPurple,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${result.overallScore}',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  '/100',
                                  style: TextStyle(color: Colors.black45),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Great teaching! Keep it up! 🎉',
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _ScoreChip(
                              label: 'Accuracy',
                              value: result.accuracy,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ScoreChip(
                              label: 'Clarity',
                              value: result.clarity,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ScoreChip(
                              label: 'Confidence',
                              value: result.confidence,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What You Did Well',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...result.didWell.map(
                        (item) => _BulletRow(
                          icon: Icons.check_circle,
                          color: Colors.green,
                          text: item,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Improvements',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...result.improvements.map(
                        (item) => _BulletRow(
                          icon: Icons.cancel,
                          color: Colors.redAccent,
                          text: item,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TypeAnswerScreen(topic: topic),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TopicSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('New Topic'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _BulletRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
