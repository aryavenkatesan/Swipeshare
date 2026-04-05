import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:profanity_filter/profanity_filter.dart';

class ProfanityUtils {
  ProfanityUtils._();

  static final ProfanityFilter _filter = ProfanityFilter();
  static bool _initialized = false;

  /// Load custom word list from bundled asset. Call once at app startup.
  static Future<void> init() async {
    if (_initialized) return;

    final jsonString = await rootBundle.loadString('assets/profanity/en.json');
    final List<dynamic> categories = json.decode(jsonString);

    final List<String> customWords = [];
    for (final category in categories) {
      final List<dynamic> dictionary = category['dictionary'] ?? [];
      for (final entry in dictionary) {
        final match = entry['match'] as String?;
        if (match == null) continue;
        // Each match field contains pipe-delimited variants
        customWords.addAll(match.split('|').map((w) => w.trim()));
      }
    }

    _filter.wordsToFilterOutList.addAll(customWords);
    _initialized = true;
  }

  // Check if text contains profanity - for messages
  static bool hasProfanity(String text) {
    return _filter.hasProfanity(text);
  }

  //for usernames and names
  static bool hasProfanityWord(String text) {
    // Get list of profane words
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    for (var word in words) {
      // Remove punctuation
      word = word.replaceAll(RegExp(r'[^\w]'), '');
      if (_filter.hasProfanity(word) && word.length > 2) {
        return true;
      }
    }
    return false;
  }

  // Censor profanity in text
  static String censor(String text, {String replaceWith = '*'}) {
    return _filter.censor(text, replaceWith: replaceWith);
  }
}
