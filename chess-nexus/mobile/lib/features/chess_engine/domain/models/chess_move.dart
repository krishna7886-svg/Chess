class ChessMove {
  final String fromSquare;
  final String toSquare;
  final String? promotion;
  final String san;
  final bool isCapture;
  final bool isCastling;
  final bool isEnPassant;
  final bool isCheck;
  final String? _uci;

  const ChessMove({
    required this.fromSquare,
    required this.toSquare,
    this.promotion,
    required this.san,
    String? uci,
    this.isCapture = false,
    this.isCastling = false,
    this.isEnPassant = false,
    this.isCheck = false,
  }) : _uci = uci;

  factory ChessMove.fromUci(
    String uci, {
    String? san,
    bool isCapture = false,
    bool isCastling = false,
    bool isEnPassant = false,
    bool isCheck = false,
  }) {
    final from = uci.substring(0, 2);
    final to = uci.substring(2, 4);
    final promo = uci.length > 4 ? uci.substring(4, 5).toLowerCase() : null;
    return ChessMove(
      fromSquare: from,
      toSquare: to,
      promotion: promo,
      san: san ?? uci,
      uci: uci,
      isCapture: isCapture,
      isCastling: isCastling,
      isEnPassant: isEnPassant,
      isCheck: isCheck,
    );
  }

  String get uci => _uci ?? '$fromSquare$toSquare${promotion ?? ''}';
}
