import 'dart:math';
import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/foundation.dart';

enum AiDifficulty {
  casual,
  intermediate,
  master,
  grandmaster,
}

extension AiDifficultyExtension on AiDifficulty {
  String get displayName {
    switch (this) {
      case AiDifficulty.casual: return 'Casual (~800)';
      case AiDifficulty.intermediate: return 'Intermediate (~1400)';
      case AiDifficulty.master: return 'Master (~1800)';
      case AiDifficulty.grandmaster: return 'Grandmaster (~2200)';
    }
  }

  int get depth {
    switch (this) {
      case AiDifficulty.casual: return 1;
      case AiDifficulty.intermediate: return 2;
      case AiDifficulty.master: return 3;
      case AiDifficulty.grandmaster: return 4;
    }
  }
}

class ChessAiService {
  static final ChessAiService _instance = ChessAiService._internal();
  factory ChessAiService() => _instance;
  ChessAiService._internal();

  static const Map<String, int> _pieceValues = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };

  /// Calculates the best move for the AI given the current game state
  Future<dynamic> computeBestMove(chess_lib.Chess game, AiDifficulty difficulty) async {
    final legalMoves = game.moves({'verbose': true});
    if (legalMoves.isEmpty) return null;

    if (difficulty == AiDifficulty.casual) {
      // Casual: Favor captures slightly, otherwise random legal move
      final captures = legalMoves.where((m) => m['captured'] != null).toList();
      if (captures.isNotEmpty && Random().nextDouble() < 0.6) {
        captures.shuffle();
        return captures.first;
      }
      legalMoves.shuffle();
      return legalMoves.first;
    }

    // Minimax with Alpha-Beta
    return compute(_minimaxRunner, {
      'fen': game.fen,
      'depth': difficulty.depth,
      'isWhite': game.turn == chess_lib.Color.WHITE,
    });
  }

  static dynamic _minimaxRunner(Map<String, dynamic> params) {
    final String fen = params['fen'];
    final int depth = params['depth'];
    final bool isWhite = params['isWhite'];

    final game = chess_lib.Chess.fromFEN(fen);
    final legalMoves = game.moves({'verbose': true});
    if (legalMoves.isEmpty) return null;

    dynamic bestMove = legalMoves.first;
    int bestScore = isWhite ? -999999 : 999999;

    for (final move in legalMoves) {
      game.move(move);
      final score = _alphaBeta(game, depth - 1, -999999, 999999, !isWhite);
      game.undo();

      if (isWhite) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }

    return bestMove;
  }

  static int _alphaBeta(chess_lib.Chess game, int depth, int alpha, int beta, bool isMaximizing) {
    if (depth <= 0 || game.game_over) {
      return _evaluateBoard(game);
    }

    final moves = game.moves({'verbose': true});

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        game.move(move);
        final evaluation = _alphaBeta(game, depth - 1, alpha, beta, false);
        game.undo();
        maxEval = max(maxEval, evaluation);
        alpha = max(alpha, evaluation);
        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        game.move(move);
        final evaluation = _alphaBeta(game, depth - 1, alpha, beta, true);
        game.undo();
        minEval = min(minEval, evaluation);
        beta = min(beta, evaluation);
        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }

  static int _evaluateBoard(chess_lib.Chess game) {
    if (game.in_checkmate) {
      return game.turn == chess_lib.Color.WHITE ? -100000 : 100000;
    }
    if (game.in_draw) {
      return 0;
    }

    int score = 0;
    final fenParts = game.fen.split(' ');
    final boardStr = fenParts[0];

    for (int i = 0; i < boardStr.length; i++) {
      final char = boardStr[i];
      if (char == '/' || int.tryParse(char) != null) continue;

      final isUpper = char == char.toUpperCase();
      final pieceLower = char.toLowerCase();
      final val = _pieceValues[pieceLower] ?? 0;

      if (isUpper) {
        score += val;
      } else {
        score -= val;
      }
    }

    return score;
  }
}
