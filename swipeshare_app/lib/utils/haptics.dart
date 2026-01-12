import 'package:haptic_feedback/haptic_feedback.dart';

Future<void> safeVibrate(HapticsType type) async {
  if (await Haptics.canVibrate()) {
    await Haptics.vibrate(type);
  }
}
