import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';
import 'package:chess_nexus/features/chess_engine/domain/models/chess_piece.dart';

class DualChessClockWidget extends StatelessWidget {
  final int whiteTimeSeconds;
  final int blackTimeSeconds;
  final PieceColor activeTurn;
  final bool isRunning;
  final VoidCallback? onPauseToggle;

  const DualChessClockWidget({
    super.key,
    required this.whiteTimeSeconds,
    required this.blackTimeSeconds,
    required this.activeTurn,
    this.isRunning = true,
    this.onPauseToggle,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // White Player Clock
        _buildClockBox(
          colorName: "WHITE",
          seconds: whiteTimeSeconds,
          isActive: activeTurn == PieceColor.white && isRunning,
          primaryColor: NexusColors.ivory,
        ),

        // Pause / Settings Indicator Icon
        IconButton(
          icon: Icon(
            isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: NexusColors.champagne,
            size: 32,
          ),
          onPressed: onPauseToggle,
        ),

        // Black Player Clock
        _buildClockBox(
          colorName: "BLACK",
          seconds: blackTimeSeconds,
          isActive: activeTurn == PieceColor.black && isRunning,
          primaryColor: NexusColors.secondaryText,
        ),
      ],
    );
  }

  Widget _buildClockBox({
    required String colorName,
    required int seconds,
    required bool isActive,
    required Color primaryColor,
  }) {
    final isDanger = seconds <= 15;

    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? NexusColors.deepForest : NexusColors.obsidian,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? (isDanger ? NexusColors.danger : NexusColors.mintAccent)
              : Colors.white12,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (isDanger ? NexusColors.danger : NexusColors.mintAccent).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Text(
            colorName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: isActive ? NexusColors.mintAccent : NexusColors.secondaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(seconds),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDanger ? NexusColors.danger : primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

