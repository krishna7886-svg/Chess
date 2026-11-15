import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/foundation.dart';

enum VoiceActionType {
  move,
  undo,
  restart,
  legalMoves,
  hint,
  position,
  repeat,
  ambiguous,
  illegal,
  unrecognized,
}

class VoiceParseResult {
  final VoiceActionType type;
  final String? san;
  final String? fromSquare;
  final String? toSquare;
  final String? promotion;
  final String spokenText;
  final String feedback;
  final List<String> candidateMoves;

  const VoiceParseResult({
    required this.type,
    this.san,
    this.fromSquare,
    this.toSquare,
    this.promotion,
    required this.spokenText,
    required this.feedback,
    this.candidateMoves = const [],
  });

  bool get isMove => type == VoiceActionType.move;
  bool get isSuccess => type == VoiceActionType.move || 
      type == VoiceActionType.undo || 
      type == VoiceActionType.restart || 
      type == VoiceActionType.legalMoves || 
      type == VoiceActionType.hint || 
      type == VoiceActionType.position;
}

class VoiceChessParser {
  /// Normalizes spoken text into phonetic chess tokens
  static String normalizeSpeech(String raw) {
    String text = raw.toLowerCase().trim();

    // Remove punctuation
    text = text.replaceAll(RegExp(r'[.,?!;:_\-]'), ' ');

    // Normalize phonetics and common speech recognizer quirks
    final replacements = {
      // Castling phonetics
      r'\b(castle\s+king\s*side|castles\s+king\s*side|kingside\s+castle|short\s+castle|castle\s+short)\b': 'o-o',
      r'\b(castle\s+queen\s*side|castles\s+queen\s*side|queenside\s+castle|long\s+castle|castle\s+long)\b': 'o-o-o',
      r'\b(castles|castle)\b': 'o-o',

      // Piece names
      r'\b(knight|night|nite|horse)\b': 'knight',
      r'\b(bishop|bishup)\b': 'bishop',
      r'\b(rook|rock|castle|rooke)\b': 'rook',
      r'\b(queen|quean)\b': 'queen',
      r'\b(king)\b': 'king',
      r'\b(pawn|pon)\b': 'pawn',

      // Actions
      r'\b(takes|take|captures|capture|kills|kill|x)\b': 'takes',
      r'\b(moves\s+to|move\s+to|going\s+to|go\s+to|to|into|on)\b': 'to',

      // Files & coordinates phonetics
      r'\b(see|sea)\s*(four|4)\b': 'c4',
      r'\b(see|sea)\s*([1-8])\b': 'c$2',
      r'\b(be|bee|before)\s*(four|4)\b': 'b4',
      r'\b(be|bee)\s*([1-8])\b': 'b$2',
      r'\b(the|dee)\s*([1-8])\b': 'd$2',
      r'\b(eat|e)\s*(four|4)\b': 'e4',
      r'\b(eff|f)\s*(three|3)\b': 'f3',
      r'\b(age|aitch)\s*([1-8])\b': 'h$2',

      // Number words to digits
      r'\bone\b': '1',
      r'\btwo\b': '2',
      r'\bthree\b': '3',
      r'\bfour\b': '4',
      r'\bfive\b': '5',
      r'\bsix\b': '6',
      r'\bseven\b': '7',
      r'\beight\b': '8',
    };

    for (final entry in replacements.entries) {
      text = text.replaceAll(RegExp(entry.key, caseSensitive: false), entry.value);
    }

    // Collapse multiple spaces
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Parses spoken text against the current legal moves of the chess position
  static VoiceParseResult parseCommand(String rawSpeech, chess_lib.Chess game) {
    if (rawSpeech.trim().isEmpty) {
      return const VoiceParseResult(
        type: VoiceActionType.unrecognized,
        spokenText: '',
        feedback: 'No voice command detected. Please speak a move.',
      );
    }

    final normalized = normalizeSpeech(rawSpeech);
    debugPrint('VoiceChessParser: raw="$rawSpeech" -> normalized="$normalized"');

    // 1. Check for system voice commands first
    if (_matchesPattern(normalized, [
      'undo', 'take back', 'takeback', 'go back', 'revert move', 'undo move'
    ])) {
      return VoiceParseResult(
        type: VoiceActionType.undo,
        spokenText: rawSpeech,
        feedback: 'Undoing last move.',
      );
    }

    if (_matchesPattern(normalized, [
      'restart', 'restart game', 'new game', 'reset', 'start over', 'play again'
    ])) {
      return VoiceParseResult(
        type: VoiceActionType.restart,
        spokenText: rawSpeech,
        feedback: 'Starting a new game.',
      );
    }

    if (_matchesPattern(normalized, [
      'what moves can i make', 'show legal moves', 'legal moves', 'what can i move',
      'show moves', 'available moves', 'help'
    ])) {
      final legalSans = game.moves();
      final preview = legalSans.take(5).join(', ');
      return VoiceParseResult(
        type: VoiceActionType.legalMoves,
        spokenText: rawSpeech,
        feedback: 'You have ${legalSans.length} legal moves. Examples: $preview.',
        candidateMoves: List<String>.from(legalSans),
      );
    }

    if (_matchesPattern(normalized, [
      'suggest a move', 'give me a hint', 'suggest', 'hint', 'what should i play',
      'best move', 'recommend a move'
    ])) {
      final legalMoves = game.moves({'verbose': true});
      if (legalMoves.isEmpty) {
        return VoiceParseResult(
          type: VoiceActionType.hint,
          spokenText: rawSpeech,
          feedback: 'Game is finished. No moves available.',
        );
      }
      // Simple tactical priority: checkmate > capture > center control > random
      dynamic best = legalMoves.first;
      for (final m in legalMoves) {
        if (m['san'].toString().contains('#')) {
          best = m;
          break;
        }
        if (m['captured'] != null) {
          best = m;
        }
      }
      return VoiceParseResult(
        type: VoiceActionType.hint,
        spokenText: rawSpeech,
        feedback: 'Suggestion: Play ${best['san']} (${_describeMove(best)}).',
        candidateMoves: [best['san'].toString()],
      );
    }

    if (_matchesPattern(normalized, [
      'current position', 'what is the position', 'whos turn', 'who is next',
      'game status', 'score'
    ])) {
      final turn = game.turn == chess_lib.Color.WHITE ? 'White' : 'Black';
      final status = game.in_check ? 'in check' : 'normal';
      return VoiceParseResult(
        type: VoiceActionType.position,
        spokenText: rawSpeech,
        feedback: "$turn's turn to move ($status). Move count: ${game.history.length}.",
      );
    }

    // 2. Parse Chess Move
    return _parseMoveCommand(normalized, rawSpeech, game);
  }

  static VoiceParseResult _parseMoveCommand(
    String normalized,
    String originalSpeech,
    chess_lib.Chess game,
  ) {
    final List<dynamic> legalMoves = game.moves({'verbose': true});
    if (legalMoves.isEmpty) {
      return VoiceParseResult(
        type: VoiceActionType.illegal,
        spokenText: originalSpeech,
        feedback: 'Game is over. No legal moves possible.',
      );
    }

    // A. Castling exact match
    if (normalized == 'o-o' || normalized.contains('kingside') || normalized == 'castle') {
      final castleKingside = legalMoves.where((m) => m['san'] == 'O-O').toList();
      if (castleKingside.isNotEmpty) {
        final m = castleKingside.first;
        return VoiceParseResult(
          type: VoiceActionType.move,
          san: 'O-O',
          fromSquare: m['from'],
          toSquare: m['to'],
          spokenText: originalSpeech,
          feedback: 'Castled kingside (O-O).',
        );
      } else {
        return VoiceParseResult(
          type: VoiceActionType.illegal,
          spokenText: originalSpeech,
          feedback: 'Kingside castling is not legal in this position.',
        );
      }
    }

    if (normalized == 'o-o-o' || normalized.contains('queenside')) {
      final castleQueenside = legalMoves.where((m) => m['san'] == 'O-O-O').toList();
      if (castleQueenside.isNotEmpty) {
        final m = castleQueenside.first;
        return VoiceParseResult(
          type: VoiceActionType.move,
          san: 'O-O-O',
          fromSquare: m['from'],
          toSquare: m['to'],
          spokenText: originalSpeech,
          feedback: 'Castled queenside (O-O-O).',
        );
      } else {
        return VoiceParseResult(
          type: VoiceActionType.illegal,
          spokenText: originalSpeech,
          feedback: 'Queenside castling is not legal in this position.',
        );
      }
    }

    // B. Direct SAN match (e.g., "e4", "Nf3", "Bxc4", "exd5")
    final cleanedSpokenToken = normalized.replaceAll(' ', '');
    for (final m in legalMoves) {
      final san = m['san'].toString();
      final cleanSan = san.replaceAll('x', '').replaceAll('+', '').replaceAll('#', '').toLowerCase();
      if (cleanSan == cleanedSpokenToken || san.toLowerCase() == normalized) {
        return VoiceParseResult(
          type: VoiceActionType.move,
          san: san,
          fromSquare: m['from'],
          toSquare: m['to'],
          promotion: m['promotion'],
          spokenText: originalSpeech,
          feedback: 'Move executed: $san (${_describeMove(m)}).',
        );
      }
    }

    // C. Coordinate notation: "e2 to e4", "e2 e4", "e2e4"
    final coordMatch = RegExp(r'\b([a-h][1-8])\s*(to|\s)?\s*([a-h][1-8])\b').firstMatch(normalized);
    if (coordMatch != null) {
      final from = coordMatch.group(1)!;
      final to = coordMatch.group(3)!;
      final matching = legalMoves.where((m) => m['from'] == from && m['to'] == to).toList();
      if (matching.isNotEmpty) {
        final m = matching.first;
        return VoiceParseResult(
          type: VoiceActionType.move,
          san: m['san'],
          fromSquare: from,
          toSquare: to,
          promotion: m['promotion'],
          spokenText: originalSpeech,
          feedback: 'Move executed: ${m['san']} (${_describeMove(m)}).',
        );
      } else {
        return VoiceParseResult(
          type: VoiceActionType.illegal,
          spokenText: originalSpeech,
          feedback: 'Move from $from to $to is not legal.',
        );
      }
    }

    // D. Natural language descriptive matching
    // Extract target square: [a-h][1-8]
    final squareMatches = RegExp(r'\b([a-h][1-8])\b').allMatches(normalized).toList();
    if (squareMatches.isNotEmpty) {
      final targetSquare = squareMatches.last.group(1)!;

      // Extract specified piece (if any)
      String? targetPieceType;
      if (normalized.contains('pawn')) targetPieceType = 'p';
      else if (normalized.contains('knight')) targetPieceType = 'n';
      else if (normalized.contains('bishop')) targetPieceType = 'b';
      else if (normalized.contains('rook')) targetPieceType = 'r';
      else if (normalized.contains('queen')) targetPieceType = 'q';
      else if (normalized.contains('king')) targetPieceType = 'k';

      // Find all legal moves landing on targetSquare
      List<dynamic> candidates = legalMoves.where((m) => m['to'] == targetSquare).toList();

      if (targetPieceType != null) {
        candidates = candidates.where((m) => m['piece'] == targetPieceType).toList();
      }

      // Check if user specified a source file/rank (e.g. "Knight from b1 to d2")
      final sourceMatch = RegExp(r'from\s+([a-h1-8])').firstMatch(normalized);
      if (sourceMatch != null) {
        final src = sourceMatch.group(1)!;
        candidates = candidates.where((m) => m['from'].contains(src)).toList();
      }

      if (candidates.length == 1) {
        final m = candidates.first;
        return VoiceParseResult(
          type: VoiceActionType.move,
          san: m['san'],
          fromSquare: m['from'],
          toSquare: m['to'],
          promotion: m['promotion'],
          spokenText: originalSpeech,
          feedback: 'Move executed: ${m['san']} (${_describeMove(m)}).',
        );
      } else if (candidates.length > 1) {
        // Disambiguation needed!
        final disambiguateOptions = candidates.map((m) => "from ${m['from']}").join(' or ');
        return VoiceParseResult(
          type: VoiceActionType.ambiguous,
          spokenText: originalSpeech,
          feedback: 'Multiple pieces can move to $targetSquare. Did you mean $disambiguateOptions?',
          candidateMoves: candidates.map((m) => m['san'].toString()).toList(),
        );
      } else {
        // Known square, but no piece can legally reach it
        final pieceName = targetPieceType != null ? _pieceName(targetPieceType) : 'piece';
        return VoiceParseResult(
          type: VoiceActionType.illegal,
          spokenText: originalSpeech,
          feedback: 'No legal move found for $pieceName to $targetSquare.',
        );
      }
    }

    // E. Unrecognized command
    return VoiceParseResult(
      type: VoiceActionType.unrecognized,
      spokenText: originalSpeech,
      feedback: 'Could not understand "$originalSpeech". Say "Pawn to e4", "Knight to f3", or "Undo".',
    );
  }

  static bool _matchesPattern(String text, List<String> patterns) {
    for (final p in patterns) {
      if (text == p || text.startsWith('$p ') || text.endsWith(' $p')) {
        return true;
      }
    }
    return false;
  }

  static String _pieceName(String type) {
    switch (type.toLowerCase()) {
      case 'p': return 'Pawn';
      case 'n': return 'Knight';
      case 'b': return 'Bishop';
      case 'r': return 'Rook';
      case 'q': return 'Queen';
      case 'k': return 'King';
      default: return 'Piece';
    }
  }

  static String _describeMove(dynamic m) {
    final piece = _pieceName(m['piece'] ?? 'p');
    final from = m['from'];
    final to = m['to'];
    final isCapture = m['captured'] != null;
    if (m['san'] == 'O-O') return 'Kingside Castle';
    if (m['san'] == 'O-O-O') return 'Queenside Castle';
    if (isCapture) {
      return '$piece on $from takes on $to';
    }
    return '$piece from $from to $to';
  }
}
