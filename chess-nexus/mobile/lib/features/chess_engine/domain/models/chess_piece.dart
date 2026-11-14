enum PieceColor { white, black }

enum PieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final PieceColor color;
  final PieceType type;

  const ChessPiece({required this.color, required this.type});

  static ChessPiece fromFenSymbol(String symbol) {
    final isWhite = symbol == symbol.toUpperCase();
    final color = isWhite ? PieceColor.white : PieceColor.black;
    final lower = symbol.toLowerCase();
    PieceType type;
    switch (lower) {
      case 'p':
        type = PieceType.pawn;
        break;
      case 'n':
        type = PieceType.knight;
        break;
      case 'b':
        type = PieceType.bishop;
        break;
      case 'r':
        type = PieceType.rook;
        break;
      case 'q':
        type = PieceType.queen;
        break;
      case 'k':
        type = PieceType.king;
        break;
      default:
        type = PieceType.pawn;
    }
    return ChessPiece(color: color, type: type);
  }

  String toFenSymbol() {
    String letter;
    switch (type) {
      case PieceType.pawn:
        letter = 'p';
        break;
      case PieceType.knight:
        letter = 'n';
        break;
      case PieceType.bishop:
        letter = 'b';
        break;
      case PieceType.rook:
        letter = 'r';
        break;
      case PieceType.queen:
        letter = 'q';
        break;
      case PieceType.king:
        letter = 'k';
        break;
    }
    return color == PieceColor.white ? letter.toUpperCase() : letter;
  }

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
