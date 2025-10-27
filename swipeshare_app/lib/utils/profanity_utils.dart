import 'package:profanity_filter/profanity_filter.dart';

class ProfanityUtils {
  // Private constructor to prevent instantiation
  ProfanityUtils._();

  // Singleton instance
  static final ProfanityFilter _filter = ProfanityFilter();

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

  // Add custom bad words
  static void addCustomWords(List<String> words) {
    // You'd need to recreate the filter with additional words
    // or keep a list and check manually
  }
}
