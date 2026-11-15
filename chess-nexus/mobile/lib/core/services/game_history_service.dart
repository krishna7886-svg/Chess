import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameRecord {
  final String id;
  final DateTime date;
  final String gameMode;
  final String result;
  final int movesCount;
  final List<String> movesSan;
  final String pgn;

  const GameRecord({
    required this.id,
    required this.date,
    required this.gameMode,
    required this.result,
    required this.movesCount,
    required this.movesSan,
    required this.pgn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'gameMode': gameMode,
        'result': result,
        'movesCount': movesCount,
        'movesSan': movesSan,
        'pgn': pgn,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        id: json['id'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        gameMode: json['gameMode'] ?? 'Voice Chess',
        result: json['result'] ?? 'Completed',
        movesCount: json['movesCount'] ?? 0,
        movesSan: List<String>.from(json['movesSan'] ?? []),
        pgn: json['pgn'] ?? '',
      );
}

class GameHistoryService {
  static const String _storageKey = 'chess_nexus_game_history';
  static final GameHistoryService _instance = GameHistoryService._internal();
  factory GameHistoryService() => _instance;
  GameHistoryService._internal();

  Future<List<GameRecord>> loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => GameRecord.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGame(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadGames();
    existing.insert(0, record); // newest first

    // Keep up to 50 recent games
    if (existing.length > 50) {
      existing.removeRange(50, existing.length);
    }

    final raw = jsonEncode(existing.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
