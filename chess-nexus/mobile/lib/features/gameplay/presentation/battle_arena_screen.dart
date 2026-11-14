import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/nexus_board.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/dual_chess_clock.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/move_tape_ribbon.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/promotion_dialog.dart';
import 'package:chess_nexus/features/analysis/presentation/widgets/eval_gauge.dart';
import 'package:chess_nexus/core/services/audio_service.dart';
import 'package:chess_nexus/core/services/haptics_service.dart';

class BattleArenaScreen extends StatefulWidget {
  const BattleArenaScreen({super.key});

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen> {
  // Game state
  Map<String, ChessPiece?> _boardState = {};
  PieceColor _orientation = PieceColor.white;
  PieceColor _currentTurn = PieceColor.white;
  String? _selectedSquare;
  List<String> _legalMoves = [];
  String? _lastMoveFrom = "e2";
  String? _lastMoveTo = "e4";
  String? _checkSquare;

  int _whiteTimeSeconds = 258; // 04:18
  int _blackTimeSeconds = 232; // 03:52
  bool _isClockRunning = true;

  final List<String> _movesSan = ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6"];
  double _evalCentipawns = 60.0; // +0.6 White

  @override
  void initState() {
    super.initState();
    _initializeStandardBoard();
  }

  void _initializeStandardBoard() {
    _boardState = {
      // White pieces
      "a1": const ChessPiece(color: PieceColor.white, type: PieceType.rook),
      "b1": const ChessPiece(color: PieceColor.white, type: PieceType.knight),
      "c1": const ChessPiece(color: PieceColor.white, type: PieceType.bishop),
      "d1": const ChessPiece(color: PieceColor.white, type: PieceType.queen),
      "e1": const ChessPiece(color: PieceColor.white, type: PieceType.king),
      "f1": const ChessPiece(color: PieceColor.white, type: PieceType.bishop),
      "g1": const ChessPiece(color: PieceColor.white, type: PieceType.knight),
      "h1": const ChessPiece(color: PieceColor.white, type: PieceType.rook),
      "a2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "b2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "c2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "d2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "e4": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "f2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "g2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "h2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),

      // Black pieces
      "a8": const ChessPiece(color: PieceColor.black, type: PieceType.rook),
      "b8": const ChessPiece(color: PieceColor.black, type: PieceType.knight),
      "c8": const ChessPiece(color: PieceColor.black, type: PieceType.bishop),
      "d8": const ChessPiece(color: PieceColor.black, type: PieceType.queen),
      "e8": const ChessPiece(color: PieceColor.black, type: PieceType.king),
      "f8": const ChessPiece(color: PieceColor.black, type: PieceType.bishop),
      "g8": const ChessPiece(color: PieceColor.black, type: PieceType.knight),
      "h8": const ChessPiece(color: PieceColor.black, type: PieceType.rook),
      "a7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "b7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "c7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "d7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "e5": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "f7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "g7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "h7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
    };
  }

  void _handleSquareSelected(String square) {
    final piece = _boardState[square];
    if (piece != null && piece.color == _currentTurn) {
      setState(() {
        _selectedSquare = square;
        // Generate pseudo candidate destinations for selected piece
        _legalMoves = _calculateCandidateMoves(square);
      });
      HapticsService.trigger(HapticIntensity.selection);
    } else {
      setState(() {
        _selectedSquare = null;
        _legalMoves = [];
      });
    }
  }

  List<String> _calculateCandidateMoves(String square) {
    final file = square[0];
    final rank = int.parse(square[1]);
    final candidates = <String>[];

    // Example forward moves
    if (rank < 8) candidates.add("$file${rank + 1}");
    if (rank > 1) candidates.add("$file${rank - 1}");
    return candidates;
  }

  void _handleMoveExecuted(String from, String to) async {
    final piece = _boardState[from];
    if (piece == null) return;

    // Check if pawn promotion
    if (piece.type == PieceType.pawn && (to.endsWith('8') || to.endsWith('1'))) {
      final promotedType = await PromotionDialog.show(context, piece.color);
      if (promotedType == null) return;
      _boardState[to] = ChessPiece(color: piece.color, type: promotedType);
      AudioService().playSound(ChessSound.promote);
    } else {
      final isCapture = _boardState[to] != null;
      _boardState[to] = piece;
      if (isCapture) {
        AudioService().playSound(ChessSound.capture);
        HapticsService.vibrateOnCapture();
      } else {
        AudioService().playSound(ChessSound.moveSelf);
        HapticsService.vibrateOnMove();
      }
    }

    _boardState.remove(from);

    setState(() {
      _lastMoveFrom = from;
      _lastMoveTo = to;
      _selectedSquare = null;
      _legalMoves = [];
      _movesSan.add("$from$to");
      _currentTurn = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rated Blitz · 3+2", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("FIDE Rated Match · Casual Arena", style: TextStyle(fontSize: 11, color: NexusColors.secondaryText)),
          ],
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 16, color: NexusColors.secondaryText),
              const SizedBox(width: 4),
              const Text("1,420", style: TextStyle(fontSize: 12, color: NexusColors.secondaryText)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.volume_up, color: NexusColors.ivory),
                onPressed: () => AudioService().toggleSound(!AudioService().isSoundEnabled),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 1. Opponent HUD (IM Nikolai Vance)
              _buildPlayerCard(
                name: "IM Nikolai Vance",
                rating: "2045",
                flag: "🇳🇴",
                title: "IM",
                isTurn: _currentTurn == PieceColor.black,
                timeSeconds: _blackTimeSeconds,
                avatar: "🧙‍♂️",
                capturedPieces: "♙ ♙ ♘",
              ),

              const SizedBox(height: 8),

              // 2. Center Chessboard + Stockfish Evaluation Gauge
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stockfish Centipawn Bar
                      EvalGaugeWidget(
                        scoreCentipawns: _evalCentipawns,
                        isVertical: true,
                      ),
                      const SizedBox(width: 8),
                      // 64-Square Nexus Board
                      Flexible(
                        child: NexusBoardWidget(
                          boardState: _boardState,
                          orientation: _orientation,
                          selectedSquare: _selectedSquare,
                          legalMoveSquares: _legalMoves,
                          lastMoveFrom: _lastMoveFrom,
                          lastMoveTo: _lastMoveTo,
                          checkSquare: _checkSquare,
                          onSquareSelected: _handleSquareSelected,
                          onMoveExecuted: _handleMoveExecuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 3. User Player HUD
              _buildPlayerCard(
                name: "Sterling A. (You)",
                rating: "1850",
                flag: "🇮🇳",
                title: "CM",
                isTurn: _currentTurn == PieceColor.white,
                timeSeconds: _whiteTimeSeconds,
                avatar: "🤖",
                capturedPieces: "♟ ♟",
              ),

              const SizedBox(height: 10),

              // 4. Move History Ribbon
              MoveTapeRibbonWidget(movesSan: _movesSan),

              const SizedBox(height: 10),

              // 5. Tactical Game Controls Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.flag, "Resign", () => _confirmResignation()),
                  _buildActionButton(Icons.handshake, "Draw", () => _showDrawOfferDialog()),
                  _buildActionButton(Icons.mic, "Voice", () => _toggleVoiceCommands()),
                  _buildActionButton(Icons.undo, "Takeback", () {}),
                  _buildActionButton(Icons.flip, "Flip", () {
                    setState(() {
                      _orientation = _orientation == PieceColor.white ? PieceColor.black : PieceColor.white;
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required String rating,
    required String flag,
    required String title,
    required bool isTurn,
    required int timeSeconds,
    required String avatar,
    required String capturedPieces,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isTurn ? NexusColors.deepForest : Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTurn ? NexusColors.mintAccent : Colors.white10,
          width: isTurn ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(avatar, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: NexusColors.champagne.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$flag $name",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NexusColors.ivory),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text("$rating Elo", style: const TextStyle(fontSize: 11, color: NexusColors.secondaryText)),
                      const SizedBox(width: 8),
                      Text(capturedPieces, style: const TextStyle(fontSize: 12, color: NexusColors.ivory)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Digital Timer Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: NexusColors.obsidian,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTurn ? NexusColors.mintAccent : Colors.white12,
              ),
            ),
            child: Text(
              _formatSeconds(timeSeconds),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isTurn ? NexusColors.mintAccent : NexusColors.ivory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NexusColors.deepForest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: NexusColors.ivory),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: NexusColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _confirmResignation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexusColors.deepForest,
        title: const Text("Resign Match?", style: TextStyle(color: NexusColors.ivory)),
        content: const Text("Are you sure you want to forfeit this match? Your rating will decrease.", style: TextStyle(color: NexusColors.secondaryText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NexusColors.danger),
            onPressed: () {
              Navigator.pop(context);
              AudioService().playSound(ChessSound.defeat);
            },
            child: const Text("Confirm Resign"),
          ),
        ],
      ),
    );
  }

  void _showDrawOfferDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Draw offer transmitted to opponent"),
        backgroundColor: NexusColors.deepForest,
      ),
    );
  }

  void _toggleVoiceCommands() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Voice Recognition Active. Say 'Play e4' or 'Castle Kingside' (English & Telugu supported)"),
        backgroundColor: NexusColors.emerald,
      ),
    );
  }
}

