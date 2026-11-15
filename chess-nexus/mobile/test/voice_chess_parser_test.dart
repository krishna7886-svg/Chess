import 'package:flutter_test/flutter_test.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_nexus/core/services/voice_chess_parser.dart';

void main() {
  group('VoiceChessParser Speech Normalization Tests', () {
    test('Normalizes phonetic pieces and coordinates correctly', () {
      expect(VoiceChessParser.normalizeSpeech('Move pawn to E4.'), 'pawn to e4');
      expect(VoiceChessParser.normalizeSpeech('Night to F3!'), 'knight to f3');
      expect(VoiceChessParser.normalizeSpeech('See four?'), 'c4');
      expect(VoiceChessParser.normalizeSpeech('Castle king side'), 'o-o');
      expect(VoiceChessParser.normalizeSpeech('Castle queen side'), 'o-o-o');
      expect(VoiceChessParser.normalizeSpeech('eat four'), 'e4');
      expect(VoiceChessParser.normalizeSpeech('eff three'), 'f3');
    });

    test('Normalizes system control commands', () {
      expect(VoiceChessParser.normalizeSpeech('Please undo move'), 'undo move');
      expect(VoiceChessParser.normalizeSpeech('Restart game now'), 'restart game now');
    });
  });

  group('VoiceChessParser Legal Move Parsing Tests', () {
    late chess_lib.Chess game;

    setUp(() {
      game = chess_lib.Chess();
    });

    test('Parses natural pawn opening: "Move pawn to E4"', () {
      final result = VoiceChessParser.parseCommand('Move pawn to E4', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'e4');
      expect(result.fromSquare, 'e2');
      expect(result.toSquare, 'e4');
      expect(result.isSuccess, isTrue);
    });

    test('Parses natural piece opening: "Knight to F3"', () {
      final result = VoiceChessParser.parseCommand('Knight to F3', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'Nf3');
      expect(result.fromSquare, 'g1');
      expect(result.toSquare, 'f3');
    });

    test('Parses direct coordinate move: "e2 to e4" or "d2 d4"', () {
      final result = VoiceChessParser.parseCommand('e2 to e4', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'e4');
      expect(result.fromSquare, 'e2');
      expect(result.toSquare, 'e4');
    });

    test('Parses direct SAN token: "e4" or "Nf3"', () {
      final result = VoiceChessParser.parseCommand('e4', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'e4');
    });

    test('Rejects illegal move: "Pawn to e5" on White\'s first move', () {
      final result = VoiceChessParser.parseCommand('Pawn to e5', game);
      expect(result.type, VoiceActionType.illegal);
      expect(result.feedback.contains('No legal move found'), isTrue);
    });

    test('Parses castling: "Castle kingside" when legal', () {
      // Setup position where White can castle kingside: 1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5
      game.move('e4');
      game.move('e5');
      game.move('Nf3');
      game.move('Nc6');
      game.move('Bc4');
      game.move('Bc5');

      final result = VoiceChessParser.parseCommand('Castle kingside', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'O-O');
      expect(result.fromSquare, 'e1');
      expect(result.toSquare, 'g1');
    });

    test('Rejects castling when illegal', () {
      final result = VoiceChessParser.parseCommand('Castle kingside', game);
      expect(result.type, VoiceActionType.illegal);
      expect(result.feedback.contains('not legal'), isTrue);
    });

    test('Parses capture move: "Bishop takes c4"', () {
      // Setup: 1. e4 e5 2. Bc4 Nf6
      game.move('e4');
      game.move('e5');
      game.move('Bc4');
      game.move('Nf6');
      game.move('d3');
      game.move('d5');
      // White bishop takes d5: "Bishop takes d5"
      final result = VoiceChessParser.parseCommand('Bishop takes d5', game);
      expect(result.type, VoiceActionType.move);
      expect(result.san, 'Bxd5');
      expect(result.fromSquare, 'c4');
      expect(result.toSquare, 'd5');
    });
  });

  group('VoiceChessParser System Commands & Assistance', () {
    late chess_lib.Chess game;

    setUp(() {
      game = chess_lib.Chess();
    });

    test('Recognizes "Undo" and "Take back"', () {
      final res1 = VoiceChessParser.parseCommand('Undo', game);
      expect(res1.type, VoiceActionType.undo);

      final res2 = VoiceChessParser.parseCommand('Take back', game);
      expect(res2.type, VoiceActionType.undo);
    });

    test('Recognizes "Restart game" and "New game"', () {
      final res1 = VoiceChessParser.parseCommand('Restart game', game);
      expect(res1.type, VoiceActionType.restart);

      final res2 = VoiceChessParser.parseCommand('New game', game);
      expect(res2.type, VoiceActionType.restart);
    });

    test('Recognizes "What moves can I make?" and returns candidate count', () {
      final result = VoiceChessParser.parseCommand('What moves can I make?', game);
      expect(result.type, VoiceActionType.legalMoves);
      expect(result.candidateMoves.length, 20); // 20 standard initial legal moves
    });

    test('Recognizes "Suggest a move" or "Give me a hint"', () {
      final result = VoiceChessParser.parseCommand('Suggest a move', game);
      expect(result.type, VoiceActionType.hint);
      expect(result.candidateMoves.isNotEmpty, isTrue);
    });
  });
}
