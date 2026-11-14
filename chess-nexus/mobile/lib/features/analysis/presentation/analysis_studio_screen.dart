import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';
import 'package:chess_nexus/features/gameplay/presentation/widgets/nexus_board.dart';
import 'package:chess_nexus/features/analysis/presentation/widgets/eval_gauge.dart';

class AnalysisStudioScreen extends StatefulWidget {
  const AnalysisStudioScreen({super.key});

  @override
  State<AnalysisStudioScreen> createState() => _AnalysisStudioScreenState();
}

class _AnalysisStudioScreenState extends State<AnalysisStudioScreen> {
  String _selectedLanguage = "en"; // "en" or "te"
  double _currentEvaluation = 340.0; // +3.4 White
  int _depth = 22;
  double _nodesMillion = 18.4;

  late Map<String, ChessPiece?> _analysisBoard;

  @override
  void initState() {
    super.initState();
    _setupAnalysisPosition();
  }

  void _setupAnalysisPosition() {
    _analysisBoard = {
      // White pieces
      "g1": const ChessPiece(color: PieceColor.white, type: PieceType.king),
      "f3": const ChessPiece(color: PieceColor.white, type: PieceType.knight),
      "c4": const ChessPiece(color: PieceColor.white, type: PieceType.bishop),
      "d1": const ChessPiece(color: PieceColor.white, type: PieceType.queen),
      "f1": const ChessPiece(color: PieceColor.white, type: PieceType.rook),
      "a1": const ChessPiece(color: PieceColor.white, type: PieceType.rook),
      "a2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "b2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "c2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "d3": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "e4": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "f2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "g2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),
      "h2": const ChessPiece(color: PieceColor.white, type: PieceType.pawn),

      // Black pieces
      "g8": const ChessPiece(color: PieceColor.black, type: PieceType.king),
      "d8": const ChessPiece(color: PieceColor.black, type: PieceType.queen), // Blunder square
      "c6": const ChessPiece(color: PieceColor.black, type: PieceType.knight),
      "e5": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "c5": const ChessPiece(color: PieceColor.black, type: PieceType.bishop),
      "f8": const ChessPiece(color: PieceColor.black, type: PieceType.rook),
      "a8": const ChessPiece(color: PieceColor.black, type: PieceType.rook),
      "a7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "b7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "c7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "d6": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "f7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "g7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
      "h7": const ChessPiece(color: PieceColor.black, type: PieceType.pawn),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Analysis Studio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "Stockfish 16 NNUE · Depth $_depth · ${_nodesMillion}M Nodes",
              style: const TextStyle(fontSize: 11, color: NexusColors.mintAccent),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Evaluation Bar Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: NexusColors.mintAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: NexusColors.mintAccent),
                        ),
                        child: const Text(
                          "+3.4 White",
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: NexusColors.mintAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "84% Win Probability",
                        style: TextStyle(fontSize: 12, color: NexusColors.secondaryText),
                      ),
                    ],
                  ),
                  const Text("Move 18... Qd8??", style: TextStyle(fontSize: 12, color: NexusColors.danger, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 10),

              // Board
              Center(
                child: NexusBoardWidget(
                  boardState: _analysisBoard,
                  orientation: PieceColor.white,
                  lastMoveFrom: "d8",
                  lastMoveTo: "d8",
                  checkSquare: "d8",
                  legalMoveSquares: const ["e5"], // Candidate move square
                ),
              ),

              const SizedBox(height: 12),

              // Multi-PV Engine Lines
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOP ENGINE VARIATIONS (Multi-PV)",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: NexusColors.secondaryText),
                    ),
                    const SizedBox(height: 8),
                    _buildPvLine(1, "+3.42", "1. Nxe5 Nxe5 2. d4 Bd6 3. dxe5 Bxe5 4. Qxd8+"),
                    const Divider(color: Colors.white10, height: 12),
                    _buildPvLine(2, "+1.90", "1. d4 exd4 2. Nxd4 Nxd4 3. Qxd4 d5"),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Gemini AI Coach Explanation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: NexusColors.emerald, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text("🤖", style: TextStyle(fontSize: 22)),
                            SizedBox(width: 8),
                            Text(
                              "Coach Gemini · AI Grandmaster",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                            ),
                          ],
                        ),
                        // Language Toggle: English vs Telugu
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: NexusColors.obsidian,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              _buildLangButton("EN", "en"),
                              _buildLangButton("తెలుగు", "te"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedLanguage == "te"
                          ? "బ్లాక్ ఆడిన Qd8 ఒక తీవ్రమైన బ్లండర్. ఇది c6 గుర్రంపై రక్షణను తొలగించింది. వైట్ వెంటనే Nxe5 ఆడి f7 పాన్ పిన్ ఆధారంగా ప్రత్యర్థి పొజిషన్ పై స్పష్టమైన ఆధిక్యం సాధించవచ్చు."
                          : "Black's move Qd8 is a critical blunder, abandoning protection of the c6 knight. White should immediately strike with 19. Nxe5!, capitalizing on the f7 pin and winning decisive material.",
                      style: const TextStyle(fontSize: 13, color: NexusColors.ivory, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Bar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bookmark_border, size: 16),
                      label: const Text("Save Vault"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Position saved to Game Vault")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text("Export PGN"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PGN copied to clipboard")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: NexusColors.emerald),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text("Share"),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPvLine(int rank, String score, String moves) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            score,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: NexusColors.mintAccent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            moves,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: NexusColors.ivory,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLangButton(String label, String code) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? NexusColors.emerald : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? NexusColors.mintAccent : NexusColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

