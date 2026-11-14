import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

enum ChessSound {
  moveSelf,
  capture,
  castle,
  moveCheck,
  promote,
  victory,
  defeat,
  illegal
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool isSoundEnabled = true;

  Future<void> playSound(ChessSound sound) async {
    if (!isSoundEnabled) return;

    String assetPath;
    switch (sound) {
      case ChessSound.moveSelf:
        assetPath = "sounds/move-self.mp3";
        break;
      case ChessSound.capture:
        assetPath = "sounds/capture.mp3";
        break;
      case ChessSound.castle:
        assetPath = "sounds/castle.mp3";
        break;
      case ChessSound.moveCheck:
        assetPath = "sounds/move-check.mp3";
        break;
      case ChessSound.promote:
        assetPath = "sounds/promote.mp3";
        break;
      default:
        assetPath = "sounds/move-self.mp3";
        break;
    }

    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Audio playback notice: $e");
    }
  }

  void toggleSound(bool enabled) {
    isSoundEnabled = enabled;
  }
}

