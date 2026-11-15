import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';

enum VoiceInteractionState {
  idle,
  listening,
  recognizing,
  validating,
  executed,
  ambiguous,
  illegal,
  error,
}

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _hasPermission = false;
  String _lastRecognizedWords = '';
  VoiceInteractionState _currentState = VoiceInteractionState.idle;

  final ValueNotifier<VoiceInteractionState> stateNotifier = 
      ValueNotifier<VoiceInteractionState>(VoiceInteractionState.idle);
  final ValueNotifier<String> transcriptNotifier = ValueNotifier<String>('');

  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;
  bool get isListening => _speech.isListening;
  VoiceInteractionState get currentState => _currentState;
  String get lastTranscript => _lastRecognizedWords;

  void _setState(VoiceInteractionState newState) {
    _currentState = newState;
    stateNotifier.value = newState;
  }

  /// Initializes the speech recognition engine and requests microphone permissions
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('SpeechService status: $status');
          if (status == 'listening') {
            _setState(VoiceInteractionState.listening);
          } else if (status == 'notListening' || status == 'done') {
            if (_currentState == VoiceInteractionState.listening) {
              _setState(VoiceInteractionState.recognizing);
            }
          }
        },
        onError: (SpeechRecognitionError errorNotification) {
          debugPrint('SpeechService error: ${errorNotification.errorMsg}');
          _setState(VoiceInteractionState.error);
        },
      );
      _hasPermission = await _speech.hasPermission;
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechService initialize exception: $e');
      _isInitialized = false;
      _hasPermission = false;
      return false;
    }
  }

  /// Starts active microphone listening
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        _setState(VoiceInteractionState.error);
        onError?.call('Speech recognition is unavailable or microphone permission was denied.');
        return;
      }
    }

    _lastRecognizedWords = '';
    transcriptNotifier.value = '';
    _setState(VoiceInteractionState.listening);

    try {
      await _speech.listen(
        onResult: (result) {
          _lastRecognizedWords = result.recognizedWords;
          transcriptNotifier.value = _lastRecognizedWords;

          if (result.finalResult) {
            _setState(VoiceInteractionState.recognizing);
            onResult(_lastRecognizedWords, true);
          } else {
            onResult(_lastRecognizedWords, false);
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      debugPrint('SpeechService listen exception: $e');
      _setState(VoiceInteractionState.error);
      onError?.call('Microphone error: $e');
    }
  }

  /// Stops listening and processes final speech
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      if (_currentState == VoiceInteractionState.listening) {
        _setState(VoiceInteractionState.recognizing);
      }
    }
  }

  /// Cancels listening without processing
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
      _setState(VoiceInteractionState.idle);
    }
  }

  void updateState(VoiceInteractionState state) {
    _setState(state);
  }
}

