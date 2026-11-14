import 'package:flutter_test/flutter_test.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';

void main() {
  group('ChessPiece Domain Model Tests', () {
    test('Correctly maps FEN symbol to PieceType and PieceColor', () {
      final whiteKnight = ChessPiece.fromFenSymbol('N');
      expect(whiteKnight.type, PieceType.knight);
      expect(whiteKnight.color, PieceColor.white);
      expect(whiteKnight.value, 3);
      expect(whiteKnight.toFenSymbol(), 'N');

      final blackQueen = ChessPiece.fromFenSymbol('q');
      expect(blackQueen.type, PieceType.queen);
      expect(blackQueen.color, PieceColor.black);
      expect(blackQueen.value, 9);
      expect(blackQueen.toFenSymbol(), 'q');
    });

    test('Generates correct preserved classic asset path', () {
      const whiteKing = ChessPiece(type: PieceType.king, color: PieceColor.white);
      expect(whiteKing.assetPath, 'assets/pieces/classic/KingW.png');

      const blackRook = ChessPiece(type: PieceType.rook, color: PieceColor.black);
      expect(blackRook.assetPath, 'assets/pieces/classic/RookB.png');

      const blackPawn = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      expect(blackPawn.assetPath, 'assets/pieces/classic/PawnB.png');

      const whiteBishop = ChessPiece(type: PieceType.bishop, color: PieceColor.white);
      expect(whiteBishop.assetPath, 'assets/pieces/classic/BishopW.png');
    });

    test('Piece value calculations reflect international standard', () {
      expect(const ChessPiece(type: PieceType.pawn, color: PieceColor.white).value, 1);
      expect(const ChessPiece(type: PieceType.knight, color: PieceColor.white).value, 3);
      expect(const ChessPiece(type: PieceType.bishop, color: PieceColor.white).value, 3);
      expect(const ChessPiece(type: PieceType.rook, color: PieceColor.white).value, 5);
      expect(const ChessPiece(type: PieceType.queen, color: PieceColor.white).value, 9);
      expect(const ChessPiece(type: PieceType.king, color: PieceColor.white).value, 0);
    });
  });
}

