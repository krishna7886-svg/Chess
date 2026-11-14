import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';
import 'package:chess_nexus/core/services/haptics_service.dart';

class NexusBoardWidget extends StatefulWidget {
  final Map<String, ChessPiece?> boardState;
  final PieceColor orientation;
  final String? selectedSquare;
  final List<String> legalMoveSquares;
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final String? checkSquare;
  final Function(String from, String to)? onMoveExecuted;
  final Function(String square)? onSquareSelected;

  const NexusBoardWidget({
    super.key,
    required this.boardState,
    this.orientation = PieceColor.white,
    this.selectedSquare,
    this.legalMoveSquares = const [],
    this.lastMoveFrom,
    this.lastMoveTo,
    this.checkSquare,
    this.onMoveExecuted,
    this.onSquareSelected,
  });

  @override
  State<NexusBoardWidget> createState() => _NexusBoardWidgetState();
}

class _NexusBoardWidgetState extends State<NexusBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexusColors.emerald, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final squareSize = constraints.maxWidth / 8;
              return Stack(
                children: [
                  // 1. Static 64-square Background Canvas
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: BoardPainter(
                      orientation: widget.orientation,
                      lastMoveFrom: widget.lastMoveFrom,
                      lastMoveTo: widget.lastMoveTo,
                      selectedSquare: widget.selectedSquare,
                      checkSquare: widget.checkSquare,
                      legalMoves: widget.legalMoveSquares,
                    ),
                  ),

                  // 2. Interactive Pieces Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final square = _getSquareFromIndex(index);
                      final piece = widget.boardState[square];

                      return DragTarget<String>(
                        onWillAcceptWithDetails: (details) => true,
                        onAcceptWithDetails: (details) {
                          final fromSquare = details.data;
                          if (fromSquare != square) {
                            widget.onMoveExecuted?.call(fromSquare, square);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () {
                              if (widget.selectedSquare != null &&
                                  widget.legalMoveSquares.contains(square)) {
                                widget.onMoveExecuted?.call(widget.selectedSquare!, square);
                              } else {
                                widget.onSquareSelected?.call(square);
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: piece != null
                                  ? Draggable<String>(
                                      data: square,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Image.asset(
                                          piece.assetPath,
                                          width: squareSize * 1.15,
                                          height: squareSize * 1.15,
                                          filterQuality: FilterQuality.medium,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.25,
                                        child: Image.asset(piece.assetPath),
                                      ),
                                      onDragStarted: () {
                                        widget.onSquareSelected?.call(square);
                                        HapticsService.vibrateOnMove();
                                      },
                                      child: Semantics(
                                        label: "${piece.color.name} ${piece.type.name} on $square",
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Image.asset(
                                            piece.assetPath,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getSquareFromIndex(int index) {
    final rankIdx = index ~/ 8;
    final fileIdx = index % 8;

    final rank = widget.orientation == PieceColor.white ? (8 - rankIdx) : (rankIdx + 1);
    final file = widget.orientation == PieceColor.white ? String.fromCharCode(97 + fileIdx) : String.fromCharCode(104 - fileIdx);

    return "$file$rank";
  }
}

class BoardPainter extends CustomPainter {
  final PieceColor orientation;
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final String? selectedSquare;
  final String? checkSquare;
  final List<String> legalMoves;

  BoardPainter({
    required this.orientation,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.selectedSquare,
    this.checkSquare,
    this.legalMoves = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sqSize = size.width / 8;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int r = 0; r < 8; r++) {
      for (int f = 0; f < 8; f++) {
        final isLight = (r + f) % 2 == 0;
        final rect = Rect.fromLTWH(f * sqSize, r * sqSize, sqSize, sqSize);

        // Square Base Fill
        final paint = Paint()
          ..color = isLight ? NexusColors.boardLight : NexusColors.boardDark;
        canvas.drawRect(rect, paint);

        final squareName = _coordToSquare(r, f);

        // Highlight Last Move
        if (squareName == lastMoveFrom || squareName == lastMoveTo) {
          canvas.drawRect(
            rect,
            Paint()..color = NexusColors.moveHighlight,
          );
        }

        // Highlight Selected Square
        if (squareName == selectedSquare) {
          canvas.drawRect(
            rect,
            Paint()..color = const Color(0x66A6D6B5),
          );
        }

        // Highlight King in Check
        if (squareName == checkSquare) {
          canvas.drawRect(
            rect,
            Paint()..color = NexusColors.checkGlow,
          );
        }

        // Legal Move Dot Indicator
        if (legalMoves.contains(squareName)) {
          final center = rect.center;
          canvas.drawCircle(
            center,
            sqSize * 0.16,
            Paint()..color = const Color(0x88A6D6B5),
          );
        }

        // Draw Edge Rank & File Coordinates
        if (f == 0) {
          final rankNum = orientation == PieceColor.white ? (8 - r).toString() : (r + 1).toString();
          textPainter.text = TextSpan(
            text: rankNum,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isLight ? NexusColors.boardDark : NexusColors.boardLight,
            ),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(rect.left + 3, rect.top + 3));
        }

        if (r == 7) {
          final fileChar = orientation == PieceColor.white ? String.fromCharCode(97 + f) : String.fromCharCode(104 - f);
          textPainter.text = TextSpan(
            text: fileChar,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isLight ? NexusColors.boardDark : NexusColors.boardLight,
            ),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(rect.right - textPainter.width - 3, rect.bottom - textPainter.height - 3));
        }
      }
    }
  }

  String _coordToSquare(int r, int f) {
    final rank = orientation == PieceColor.white ? (8 - r) : (r + 1);
    final file = orientation == PieceColor.white ? String.fromCharCode(97 + f) : String.fromCharCode(104 - f);
    return "$file$rank";
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}

