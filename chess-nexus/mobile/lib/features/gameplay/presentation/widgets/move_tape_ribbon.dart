import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';

class MoveTapeRibbonWidget extends StatelessWidget {
  final List<String> movesSan;
  final int currentMoveIndex;
  final Function(int moveIndex)? onMoveSelected;

  const MoveTapeRibbonWidget({
    super.key,
    required this.movesSan,
    this.currentMoveIndex = -1,
    this.onMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (movesSan.isEmpty) {
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NexusColors.deepForest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: const Text(
          "Game Start · 1. e4",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: NexusColors.secondaryText,
          ),
        ),
      );
    }

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: (movesSan.length / 2).ceil(),
        itemBuilder: (context, index) {
          final moveNum = index + 1;
          final whiteIdx = index * 2;
          final blackIdx = whiteIdx + 1;

          final whiteMove = movesSan[whiteIdx];
          final blackMove = blackIdx < movesSan.length ? movesSan[blackIdx] : null;

          return Row(
            children: [
              Text(
                "$moveNum. ",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: NexusColors.secondaryText,
                ),
              ),
              _buildMoveChip(whiteMove, whiteIdx),
              if (blackMove != null) ...[
                const SizedBox(width: 4),
                _buildMoveChip(blackMove, blackIdx),
              ],
              const SizedBox(width: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoveChip(String san, int index) {
    final isSelected = currentMoveIndex == index;

    return InkWell(
      onTap: () => onMoveSelected?.call(index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? NexusColors.emerald : Colors.black26,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? NexusColors.mintAccent : Colors.white10,
          ),
        ),
        child: Text(
          san,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? NexusColors.mintAccent : NexusColors.ivory,
          ),
        ),
      ),
    );
  }
}

