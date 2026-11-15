import 'package:flutter_test/flutter_test.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_nexus/features/chess_engine/services/chess_ai_service.dart';
import 'package:chess_nexus/core/services/game_history_service.dart';

void main() {
  group('ChessAiService Verification', () {
    late chess_lib.Chess game;
    late ChessAiService ai;

    setUp(() {
      game = chess_lib.Chess();
      ai = ChessAiService();
    });

    test('Computes legal move on Casual difficulty', () async {
      final move = await ai.computeBestMove(game, AiDifficulty.casual);
      expect(move, isNotNull);
      final from = move['from'] as String;
      final to = move['to'] as String;
      expect(from.length, 2);
      expect(to.length, 2);
    });

    test('AI difficulty names and search depths', () {
      expect(AiDifficulty.casual.depth, 1);
      expect(AiDifficulty.intermediate.depth, 2);
      expect(AiDifficulty.master.depth, 3);
      expect(AiDifficulty.grandmaster.depth, 4);
    });
  });

  group('GameRecord Serialization', () {
    test('Serializes and deserializes cleanly', () {
      final now = DateTime.now();
      final record = GameRecord(
        id: '12345',
        date: now,
        gameMode: 'Voice vs AI',
        result: 'White Won (1-0)',
        movesCount: 24,
        movesSan: ['e4', 'e5', 'Nf3', 'Nc6'],
        pgn: '1. e4 e5 2. Nf3 Nc6',
      );

      final json = record.toJson();
      final revived = GameRecord.fromJson(json);

      expect(revived.id, '12345');
      expect(revived.gameMode, 'Voice vs AI');
      expect(revived.result, 'White Won (1-0)');
      expect(revived.movesCount, 24);
      expect(revived.movesSan.length, 4);
      expect(revived.pgn, '1. e4 e5 2. Nf3 Nc6');
    });
  });
}

