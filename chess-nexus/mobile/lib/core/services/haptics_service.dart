import 'package:flutter/services.dart';

enum HapticIntensity { light, medium, heavy, selection }

class HapticsService {
  static bool isHapticsEnabled = true;

  static void trigger(HapticIntensity intensity) {
    if (!isHapticsEnabled) return;

    switch (intensity) {
      case HapticIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticIntensity.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  static void vibrateOnMove() => trigger(HapticIntensity.light);
  static void vibrateOnCapture() => trigger(HapticIntensity.medium);
  static void vibrateOnCheck() => trigger(HapticIntensity.heavy);
}

