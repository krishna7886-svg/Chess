import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable host override (can be set at runtime or via --dart-define)
  static const String _envHost = String.fromEnvironment('API_HOST', defaultValue: '');

  static String get baseHttpUrl {
    if (_envHost.isNotEmpty) {
      return "http://$_envHost";
    }
    if (kDebugMode) {
      // In debug mode, route to local FastAPI development server
      if (Platform.isAndroid) {
        // 10.0.2.2 is the Android Emulator loopback alias for the host machine.
        // For physical devices connected via ADB, run 'adb reverse tcp:8000 tcp:8000'
        // to forward localhost directly.
        return "http://10.0.2.2:8000";
      }
      return "http://127.0.0.1:8000";
    }
    return "https://api.chessnexus.app";
  }

  static String get baseWsUrl {
    if (_envHost.isNotEmpty) {
      return "ws://$_envHost";
    }
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return "ws://10.0.2.2:8000";
      }
      return "ws://127.0.0.1:8000";
    }
    return "wss://api.chessnexus.app";
  }

  // Endpoints
  static const String authRegister = "/api/v1/auth/register";
  static const String authLogin = "/api/v1/auth/login";
  static const String authGuest = "/api/v1/auth/guest";
  static const String matchesCreate = "/api/v1/matches/create";
  static const String matchesJoin = "/api/v1/matches/join";
  static const String coachExplain = "/api/v1/coach/explain-position";
  static const String coachVoice = "/api/v1/coach/parse-voice";
  static const String tournaments = "/api/v1/tournaments/";
  static const String puzzlesDaily = "/api/v1/puzzles/daily";
}
