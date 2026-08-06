import 'dart:convert';
import 'package:http/http.dart' as http;

/// ⚠️ Uses the same API key setup as ai_grading_service.dart — see
/// that file's security note. Set your key below before this works.
const String _anthropicApiKey = 'YOUR_API_KEY_HERE';

/// Generates a plain-text explanation answering the user's question.
/// Separate from AiGradingService: that one grades what the *user*
/// said; this one answers a question *for* the user.
class AiAnswerService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  static Future<String> getAnswer(String question) async {
    if (_anthropicApiKey == 'YOUR_API_KEY_HERE' || _anthropicApiKey.isEmpty) {
      throw Exception(
        'No Anthropic API key set. Add one in ai_answer_service.dart.',
      );
    }

    final prompt =
        '''
Answer the following question clearly and concisely, as if explaining
it to someone trying to learn the topic. Plain text only — no
markdown formatting, no headers, no bullet symbols like * or -, just
well-organized prose. Keep it under 200 words.

Question: "$question"
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _anthropicApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-6',
        'max_tokens': 500,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final contentBlocks = data['content'] as List;
    final text = contentBlocks
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n')
        .trim();

    return text;
  }
}
