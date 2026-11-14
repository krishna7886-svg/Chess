import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final Function(PieceType) onPieceSelected;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.onPieceSelected,
  });

  static Future<PieceType?> show(BuildContext context, PieceColor color) {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PromotionDialog(
        color: color,
        onPieceSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pieces = [
      PieceType.queen,
      PieceType.rook,
      PieceType.bishop,
      PieceType.knight,
    ];

    return Dialog(
      backgroundColor: NexusColors.deepForest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: NexusColors.emerald, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Promote Pawn",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NexusColors.ivory,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pieces.map((type) {
                final piece = ChessPiece(color: color, type: type);
                return InkWell(
                  onTap: () => onPieceSelected(type),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NexusColors.obsidian,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Image.asset(piece.assetPath, width: 48, height: 48),
                        const SizedBox(height: 6),
                        Text(
                          type.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: NexusColors.mintAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

