import 'package:flutter_test/flutter_test.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_move.dart';

void main() {
  group('ChessMove Domain Model Tests', () {
    test('Constructs move from UCI string with promotion', () {
      final move = ChessMove.fromUci('e7e8q', san: 'e8=Q#');
      expect(move.fromSquare, 'e7');
      expect(move.toSquare, 'e8');
      expect(move.promotion, 'q');
      expect(move.uci, 'e7e8q');
      expect(move.san, 'e8=Q#');
    });

    test('Constructs standard quiet move and captures', () {
      final quiet = ChessMove.fromUci('e2e4', san: 'e4');
      expect(quiet.fromSquare, 'e2');
      expect(quiet.toSquare, 'e4');
      expect(quiet.promotion, isNull);
      expect(quiet.uci, 'e2e4');

      final capture = ChessMove(
        fromSquare: 'e4',
        toSquare: 'd5',
        san: 'exd5',
        uci: 'e4d5',
        isCapture: true,
      );
      expect(capture.isCapture, isTrue);
      expect(capture.uci, 'e4d5');
    });
  });
}

