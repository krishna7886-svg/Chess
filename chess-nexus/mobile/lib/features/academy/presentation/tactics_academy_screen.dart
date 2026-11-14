import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/nexus_board.dart';
import 'package:chess_nexus/core/services/audio_service.dart';

class TacticsAcademyScreen extends StatefulWidget {
  const TacticsAcademyScreen({super.key});

  @override
  State<TacticsAcademyScreen> createState() => _TacticsAcademyScreenState();
}

class _TacticsAcademyScreenState extends State<TacticsAcademyScreen> {
  late Map<String, ChessPiece?> _puzzleBoard;
  String? _selectedSquare;
  List<String> _legalMoves = [];
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _loadTacticalPuzzle();
  }

  void _loadTacticalPuzzle() {
    // Setup Back-Rank Deflection Puzzle:
    // White: King g1, Rook e1, Pawns f2, g2, h2
    // Black: King g8, Rook f8, Pawns f7, g7, h7
    _puzzleBoard = {
      "g1": const ChessPiece(color: PieceColor.white, type: PieceType.king),
      "e1": const ChessPiece(color: PieceColor.white, type: PieceType.rook),
      "f2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "g2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "h2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "g8": const ChessPiece(color: PieceColor.black, type: PieceType.king),
      "f8": const ChessPiece(color: PieceColor.black, type: PieceType.rook),
      "f7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "g7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "h7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
    };
    _selectedSquare = null;
    _legalMoves = [];
    _isSolved = false;
  }

  void _handleSquareSelected(String square) {
    if (square == "e1") {
      setState(() {
        _selectedSquare = "e1";
        _legalMoves = ["e8"];
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _legalMoves = [];
      });
    }
  }

  void _handleMoveExecuted(String from, String to) {
    if (from == "e1" && to == "e8") {
      // Correct puzzle solution!
      setState(() {
        _puzzleBoard[to] = _puzzleBoard[from];
        _puzzleBoard.remove(from);
        _isSolved = true;
      });
      AudioService().playSound(ChessSound.victory);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 PUZZLE SOLVED! +18 Rating Gained! Back-rank mate achieved."),
          backgroundColor: NexusColors.success,
        ),
      );
    } else {
      AudioService().playSound(ChessSound.illegal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect move. Try calculating forcing moves."),
          backgroundColor: NexusColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        title: const Text("Tactics Academy", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NexusColors.champagne.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusColors.champagne),
            ),
            child: const Row(
              children: [
                Text("2150 Elo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusColors.champagne)),
                SizedBox(width: 4),
                Icon(Icons.star, size: 14, color: NexusColors.champagne),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("12 🔥", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Objective Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: NexusColors.mintAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "⚪ White to move · Mate in 1",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: NexusColors.ivory,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lightbulb_outline, size: 14, color: NexusColors.champagne),
                    label: const Text("GM Hint", style: TextStyle(fontSize: 11, color: NexusColors.champagne)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      side: const BorderSide(color: NexusColors.champagne),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hint: The black king is trapped behind its own pawns on the 8th rank. Look for Re8#!"),
                          backgroundColor: NexusColors.deepForest,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tactical Board
              Center(
                child: NexusBoardWidget(
                  boardState: _puzzleBoard,
                  orientation: PieceColor.white,
                  selectedSquare: _selectedSquare,
                  legalMoveSquares: _legalMoves,
                  onSquareSelected: _handleSquareSelected,
                  onMoveExecuted: _handleMoveExecuted,
                ),
              ),

              const SizedBox(height: 16),

              // Tactical Theme Chips
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TACTICAL THEME: BACK RANK DEFLECTION",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: NexusColors.mintAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildThemeChip("Back Rank Mate"),
                        _buildThemeChip("Deflection"),
                        _buildThemeChip("Overloaded Rook"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // AI Coach Tip Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.emerald),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🤖", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Grandmaster Coach Magnus",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "\"The black king has no luft (escape square). White's rook delivers an unstoppable back-rank mate with Re8#.\"",
                            style: TextStyle(fontSize: 12, color: NexusColors.ivory, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Bar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loadTacticalPuzzle,
                      child: const Text("RETRY ↺"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: NexusColors.mintAccent),
                      onPressed: () {
                        _loadTacticalPuzzle();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Loading next tactical puzzle...")),
                        );
                      },
                      child: const Text("NEXT PUZZLE →", style: TextStyle(color: NexusColors.obsidian)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NexusColors.obsidian,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: NexusColors.secondaryText),
      ),
    );
  }
}

