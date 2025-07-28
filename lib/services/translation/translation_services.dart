import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  static final String _rapidApiKey = dotenv.env['TRANSLATION_RAPIDAPI_KEY'] ?? '';
  static final String _apiUrl = dotenv.env['TRANSLATION_API_URL'] ?? '';

  // Translate text to target language
  static Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-host': 'google-translate113.p.rapidapi.com',
          'x-rapidapi-key': _rapidApiKey,
        },
        body: json.encode({
          'from': 'auto', // Auto-detect source language
          'to': targetLanguage,
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Based on the API response structure, the translated text should be in 'trans' field
        final translatedText = data['trans'] ?? text;
        return translatedText;
      } else {
        print('Translation API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return text; // Return original text if translation fails
      }
    } catch (e) {
      print('Translation Error: $e');
      return text; // Return original text if error occurs
    }
  }

  // Get user's preferred language from Firestore
  static Future<String> getUserLanguage(String userId) async {
    try {
      // This will be called from ChatService
      return 'en'; // Default fallback
    } catch (e) {
      print('Error getting user language: $e');
      return 'en'; // Default to English
    }
  }
}