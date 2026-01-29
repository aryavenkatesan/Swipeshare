import 'dart:math';

/// Centralized snackbar messages with personality
/// Frequently shown messages have multiple variations that are randomly selected.
class SnackbarMessages {
  static final _random = Random();

  // ========== PROFANITY MESSAGES ==========
  static String get profanityInMessage => _randomPick([
        "Whoa there! Let's keep it friendly",
        "That language won't fly here",
        "Keep it clean, friend",
        "Let's try that again with nicer words",
      ]);

  static String get profanityInName => _randomPick([
        "Name contains profanity, please choose another",
        "Let's keep it clean with that name",
        "Try a friendlier name",
      ]);

  // ========== ORDER MESSAGES ==========
  static String get orderPlaced => _randomPick([
        "Swipe request sent!",
        "Order confirmed! Get ready to feast",
        "Success! Your swipe is being fulfilled",
        "All set! Enjoy your meal",
        "Swipe matched! Food incoming",
      ]);

  static String orderFailed(String error) => "Order failed: $error";

  // ========== LOGIN & SIGNUP MESSAGES ==========
  static String get fillAllFields => _randomPick([
        "Looks like you missed a spot! Fill in all fields",
        "Almost there! Just need a bit more info",
        "Hold up! We need all the details",
      ]);

  static String get passwordsDontMatch => _randomPick([
        "Hmm, those passwords don't match",
        "Password mismatch! Try again",
        "Close, but those passwords need to be twins",
        "Passwords should match exactly",
      ]);

  static const nameToolong =
      "That's a mouthful! How about a shorter version?";

  static const uncEmailRequired = "Please use your UNC email (@unc.edu)";

  static const enterEmailAndPassword = "We'll need both your email and password";

  // ========== PASSWORD RESET MESSAGES ==========
  static const enterStudentEmail = "Drop your student email here";

  static const passwordTooShort =
      "Password needs at least 6 characters! Make it strong";

  static const passwordResetSuccess = "Password updated! You're all set";

  // ========== CHAT MESSAGES ==========
  static const provideReason = "Hold up! We need to know why";

  static String get chatDeleted => _randomPick([
        "Chat deleted successfully",
        "Chat's gone! Like it never happened",
        "All clean! Chat has been removed",
      ]);

  // ========== VERIFICATION MESSAGES ==========
  static const enterAllDigits = "Hold up! Need all 6 digits";

  static String get emailVerified => _randomPick([
        "Email verified! You're all set",
        "Verified! Welcome to SwipeShare",
        "Success! Email confirmed",
      ]);

  static const verificationCodeSent = "New code sent! Check your email";

  // ========== SETTINGS MESSAGES ==========
  static String get paymentMethodsUpdated => _randomPick([
        "Payment methods updated",
        "All set! Preferences saved",
        "Updated successfully",
      ]);

  // ========== FEEDBACK MESSAGES ==========
  static String get feedbackSubmitted => _randomPick([
        "Thanks for the feedback",
        "Got it! We appreciate your input",
        "Feedback received! Thank you",
        "Get back to swiping, we've got this",
      ]);

  static const reportSubmitted = "Thanks for reporting! We'll review this ASAP";

  // ========== GENERIC ERROR MESSAGES ==========
  static String genericError(String error) => "Error: $error";

  /// Randomly picks one message from the provided list
  static String _randomPick(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }
}
