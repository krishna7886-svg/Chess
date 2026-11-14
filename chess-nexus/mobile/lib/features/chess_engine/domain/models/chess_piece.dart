enum PieceColor { white, black }

enum PieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final PieceColor color;
  final PieceType type;

  const ChessPiece({required this.color, required this.type});

  String get assetPath {
    final prefix = type.name[0].toUpperCase() + type.name.substring(1);
    final suffix = color == PieceColor.white ? 'W' : 'B';
    return 'assets/pieces/classic/$prefix$suffix.png';
  }

  String get symbol {
    switch (type) {
      case PieceType.pawn:
        return color == PieceColor.white ? '♙' : '♟';
      case PieceType.knight:
        return color == PieceColor.white ? '♘' : '♞';
      case PieceType.bishop:
        return color == PieceColor.white ? '♗' : '♝';
      case PieceType.rook:
        return color == PieceColor.white ? '♖' : '♜';
      case PieceType.queen:
        return color == PieceColor.white ? '♕' : '♛';
      case PieceType.king:
        return color == PieceColor.white ? '♔' : '♚';
    }
  }

  int get value {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 3;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 0;
    }
  }
}

