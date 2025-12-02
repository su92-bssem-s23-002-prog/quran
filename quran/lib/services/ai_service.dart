import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  AiService._();

  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  // Use Gemini 1.5 Flash for low-latency Q&A; upgrade to Pro for deeper answers
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  static Future<String> ask(String question) async {
    if (_apiKey.isEmpty) {
      return 'AI not configured. Add GEMINI_API_KEY to .env.';
    }
    final prompt = _systemPrompt(question);
    try {
      final resp = await _model.generateContent([Content.text(prompt)]);
      final text = resp.text?.trim();
      if (text == null || text.isEmpty) {
        return 'No answer received. Please try again.';
      }
      return text;
    } catch (e) {
      return 'AI error: ${e.toString()}';
    }
  }

  // Adds guidance and constraints for Islamic Q&A
  static String _systemPrompt(String user) {
    return 'You are an assistant for an Islamic app.\n'
        '- Answer clearly and concisely.\n'
        '- If asked about Quran verses, include Surah name and ayah number when known.\n'
        '- Prefer referencing authentic sources (Quran, Sahih Hadith). Avoid speculative rulings.\n'
        '- For differences of opinion, briefly mention major schools without asserting one as absolute.\n'
        '- Avoid medical, legal, or extreme content; suggest consulting qualified scholars where appropriate.\n'
        '- If the question is unrelated to Islam/Quran/app features, respond briefly and steer back to helpful topics.\n\n'
        'User question: $user';
  }
}
