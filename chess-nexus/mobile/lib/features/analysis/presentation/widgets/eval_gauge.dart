import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';

class EvalGaugeWidget extends StatelessWidget {
  final double scoreCentipawns;
  final bool isVertical;

  const EvalGaugeWidget({
    super.key,
    required this.scoreCentipawns,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    // Sigmoid curve clamp between 5% and 95%
    final pawnScore = scoreCentipawns / 100.0;
    final whiteShare = (50.0 + (pawnScore * 8.0)).clamp(5.0, 95.0) / 100.0;

    final scoreText = pawnScore > 0
        ? "+${pawnScore.toStringAsFixed(1)}"
        : pawnScore.toStringAsFixed(1);

    if (isVertical) {
      return Container(
        width: 24,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Column(
            children: [
              // Black Share (Top)
              Expanded(
                flex: ((1.0 - whiteShare) * 1000).toInt(),
                child: Container(color: const Color(0xFF1F2421)),
              ),
              // White Share (Bottom)
              Expanded(
                flex: (whiteShare * 1000).toInt(),
                child: Container(
                  color: NexusColors.ivory,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 4),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      scoreText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Row(
            children: [
              Expanded(
                flex: (whiteShare * 1000).toInt(),
                child: Container(color: NexusColors.ivory),
              ),
              Expanded(
                flex: ((1.0 - whiteShare) * 1000).toInt(),
                child: Container(color: const Color(0xFF1F2421)),
              ),
            ],
          ),
        ),
      );
    }
  }
}

