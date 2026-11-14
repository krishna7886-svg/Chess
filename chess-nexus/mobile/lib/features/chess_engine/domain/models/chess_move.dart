import 'chess_piece.dart';

class ChessMove {
  final String fromSquare;
  final String toSquare;
  final PieceType? promotion;
  final String san;
  final bool isCapture;
  final bool isCastling;
  final bool isEnPassant;
  final bool isCheck;

  const ChessMove({
    required this.fromSquare,
    required this.toSquare,
    this.promotion,
    required this.san,
    this.isCapture = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isCheck = false,
  });

  String get uci {
    final promoStr = promotion != null ? promotion!.name[0].toLowerCase() : '';
    return '$fromSquare$toSquare$promoStr';
  }
}

