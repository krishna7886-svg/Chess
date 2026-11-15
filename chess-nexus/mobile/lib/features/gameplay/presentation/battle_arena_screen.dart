import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/voice_chess_parser.dart';
import '../../../core/services/game_history_service.dart';
import '../../chess_engine/domain/models/chess_piece.dart';
import '../../chess_engine/services/chess_ai_service.dart';
import 'widgets/nexus_board.dart';
import 'widgets/move_tape_ribbon.dart';
import 'widgets/promotion_dialog.dart';

enum GameMode {
  voiceAi,
  touchAi,
  twoPlayer,
}

extension GameModeExtension on GameMode {
  String get label {
    switch (this) {
      case GameMode.voiceAi: return 'Voice vs AI';
      case GameMode.touchAi: return 'Touch vs AI';
      case GameMode.twoPlayer: return '2-Player Local';
    }
  }
}

class BattleArenaScreen extends StatefulWidget {
  const BattleArenaScreen({super.key});

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen> with SingleTickerProviderStateMixin {
  late chess_lib.Chess _game;
  Map<String, ChessPiece?> _boardState = {};

  GameMode _gameMode = GameMode.voiceAi;
  AiDifficulty _aiDifficulty = AiDifficulty.intermediate;
  PieceColor _playerColor = PieceColor.white;

  String? _selectedSquare;
  List<String> _legalDestinations = [];
  String? _lastMoveFrom;
  String? _lastMoveTo;
  String? _checkSquare;

  bool _isAiThinking = false;
  String _voiceFeedback = "Tap microphone to speak your move (e.g. 'Pawn to e4')";
  VoiceInteractionState _voiceState = VoiceInteractionState.idle;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription? _transcriptSub;

  final AudioService _audio = AudioService();
  final SpeechService _speech = SpeechService();
  final ChessAiService _ai = ChessAiService();
  final GameHistoryService _history = GameHistoryService();

  @override
  void initState() {
    super.initState();
    _game = chess_lib.Chess();
    _syncBoardState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _speech.stateNotifier.addListener(_onSpeechStateChanged);
    _speech.transcriptNotifier.addListener(_onTranscriptChanged);

    // Warm up speech recognizer in background
    _speech.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stateNotifier.removeListener(_onSpeechStateChanged);
    _speech.transcriptNotifier.removeListener(_onTranscriptChanged);
    _transcriptSub?.cancel();
    super.dispose();
  }

  void _onSpeechStateChanged() {
    if (mounted) {
      setState(() {
        _voiceState = _speech.currentState;
      });
    }
  }

  void _onTranscriptChanged() {
    if (mounted && _speech.lastTranscript.isNotEmpty) {
      setState(() {
        _voiceFeedback = '"${_speech.lastTranscript}"';
      });
    }
  }

  void _syncBoardState() {
    final Map<String, ChessPiece?> newBoard = {};
    for (int rank = 1; rank <= 8; rank++) {
      for (int f = 0; f < 8; f++) {
        final file = String.fromCharCode(97 + f);
        final sq = '$file$rank';
        final piece = _game.get(sq);
        if (piece != null) {
          final sym = piece.color == chess_lib.Color.WHITE
              ? piece.type.toUpperCase()
              : piece.type.toLowerCase();
          newBoard[sq] = ChessPiece.fromFenSymbol(sym);
        } else {
          newBoard[sq] = null;
        }
      }
    }

    _boardState = newBoard;

    // Check square detection
    if (_game.in_check) {
      final turnColor = _game.turn == chess_lib.Color.WHITE ? PieceColor.white : PieceColor.black;
      for (final entry in _boardState.entries) {
        if (entry.value != null &&
            entry.value!.type == PieceType.king &&
            entry.value!.color == turnColor) {
          _checkSquare = entry.key;
          break;
        }
      }
    } else {
      _checkSquare = null;
    }
  }

  // =========================================================================
  // VOICE CONTROL INTERACTION
  // =========================================================================

  Future<void> _toggleVoiceListening() async {
    if (_speech.isListening) {
      await _speech.stopListening();
      setState(() {
        _voiceFeedback = "Processing voice command...";
      });
    } else {
      if (_game.game_over) {
        setState(() {
          _voiceFeedback = "Game is over. Tap 'New Game' or say 'Restart'.";
        });
        return;
      }

      if (_isAiThinking) {
        setState(() {
          _voiceFeedback = "AI is thinking. Please wait...";
        });
        return;
      }

      HapticsService.trigger(HapticIntensity.medium);
      setState(() {
        _voiceFeedback = "Listening... Speak your move (e.g. 'Knight to f3')";
      });

      await _speech.startListening(
        onResult: (spokenWords, isFinal) {
          if (isFinal && spokenWords.trim().isNotEmpty) {
            _handleSpokenCommand(spokenWords);
          }
        },
        onError: (error) {
          setState(() {
            _voiceFeedback = "Microphone notice: $error";
            _voiceState = VoiceInteractionState.error;
          });
        },
      );
    }
  }

  void _handleSpokenCommand(String spoken) {
    setState(() {
      _voiceState = VoiceInteractionState.validating;
      _voiceFeedback = 'Recognized: "$spoken". Validating...';
    });

    final result = VoiceChessParser.parseCommand(spoken, _game);

    switch (result.type) {
      case VoiceActionType.move:
        _executeMove(result.fromSquare!, result.toSquare!, promotion: result.promotion);
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
        });
        break;

      case VoiceActionType.undo:
        _handleUndo();
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
        });
        break;

      case VoiceActionType.restart:
        _startNewGame();
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
        });
        break;

      case VoiceActionType.legalMoves:
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
          _highlightAllLegalPieces();
        });
        break;

      case VoiceActionType.hint:
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
        });
        break;

      case VoiceActionType.position:
        setState(() {
          _voiceState = VoiceInteractionState.executed;
          _voiceFeedback = result.feedback;
        });
        break;

      case VoiceActionType.ambiguous:
        setState(() {
          _voiceState = VoiceInteractionState.ambiguous;
          _voiceFeedback = result.feedback;
        });
        HapticsService.trigger(HapticIntensity.heavy);
        break;

      case VoiceActionType.illegal:
        setState(() {
          _voiceState = VoiceInteractionState.illegal;
          _voiceFeedback = result.feedback;
        });
        _audio.playSound(ChessSound.illegal);
        HapticsService.trigger(HapticIntensity.heavy);
        break;

      case VoiceActionType.unrecognized:
      default:
        setState(() {
          _voiceState = VoiceInteractionState.error;
          _voiceFeedback = result.feedback;
        });
        break;
    }
  }

  void _highlightAllLegalPieces() {
    final moves = _game.moves({'verbose': true});
    final fromSquares = moves.map((m) => m['from'] as String).toSet().toList();
    setState(() {
      _legalDestinations = fromSquares;
    });
  }

  // =========================================================================
  // TOUCH CHESSBOARD INTERACTION
  // =========================================================================

  void _handleSquareSelected(String square) {
    if (_isAiThinking || _game.game_over) return;

    final currentTurnColor = _game.turn == chess_lib.Color.WHITE ? PieceColor.white : PieceColor.black;
    final piece = _boardState[square];

    // 1. If clicking on piece of current turn, select it and show legal moves
    if (piece != null && piece.color == currentTurnColor) {
      final verboseMoves = _game.moves({'verbose': true});
      final pieceMoves = verboseMoves.where((m) => m['from'] == square).toList();
      final destinations = pieceMoves.map((m) => m['to'] as String).toList();

      setState(() {
        _selectedSquare = square;
        _legalDestinations = destinations;
      });
      HapticsService.trigger(HapticIntensity.selection);
      return;
    }

    // 2. If a piece is already selected and target square is a legal destination
    if (_selectedSquare != null && _legalDestinations.contains(square)) {
      _executeMove(_selectedSquare!, square);
      return;
    }

    // 3. Deselect
    setState(() {
      _selectedSquare = null;
      _legalDestinations = [];
    });
  }

  void _executeMove(String from, String to, {String? promotion}) {
    // Check if move is a pawn promotion
    final piece = _game.get(from);
    final isPawn = piece != null && piece.type.toLowerCase() == 'p';
    final targetRank = to[1];
    final isPromotion = isPawn && (targetRank == '8' || targetRank == '1');

    if (isPromotion && promotion == null) {
      _showPromotionDialog(from, to);
      return;
    }

    final moveParams = {
      'from': from,
      'to': to,
      if (promotion != null) 'promotion': promotion,
    };

    final isCapture = _game.get(to) != null;
    final executed = _game.move(moveParams);

    if (executed != null) {
      _lastMoveFrom = from;
      _lastMoveTo = to;
      _selectedSquare = null;
      _legalDestinations = [];
      _syncBoardState();

      // Sound and Haptics
      if (_game.in_check) {
        _audio.playSound(ChessSound.moveCheck);
        HapticsService.trigger(HapticIntensity.heavy);
      } else if (isCapture) {
        _audio.playSound(ChessSound.capture);
        HapticsService.trigger(HapticIntensity.medium);
      } else if (to == 'g1' || to == 'c1' || to == 'g8' || to == 'c8') {
        _audio.playSound(ChessSound.castle);
        HapticsService.vibrateOnMove();
      } else {
        _audio.playSound(ChessSound.moveSelf);
        HapticsService.vibrateOnMove();
      }

      setState(() {});

      // Check game termination
      if (_checkGameOver()) return;

      // Trigger AI move if in AI mode and it's AI's turn
      if (_isAiTurn()) {
        _triggerAiMove();
      }
    }
  }

  bool _isAiTurn() {
    if (_gameMode == GameMode.twoPlayer) return false;
    final currentTurnColor = _game.turn == chess_lib.Color.WHITE ? PieceColor.white : PieceColor.black;
    return currentTurnColor != _playerColor;
  }

  Future<void> _triggerAiMove() async {
    setState(() {
      _isAiThinking = true;
      _voiceFeedback = "AI is calculating best move...";
    });

    await Future.delayed(const Duration(milliseconds: 400));
    final aiMove = await _ai.computeBestMove(_game, _aiDifficulty);

    if (aiMove != null && mounted) {
      final from = aiMove['from'];
      final to = aiMove['to'];
      final promo = aiMove['promotion'];
      final san = aiMove['san'];

      _game.move({
        'from': from,
        'to': to,
        if (promo != null) 'promotion': promo,
      });

      _lastMoveFrom = from;
      _lastMoveTo = to;
      _syncBoardState();

      if (_game.in_check) {
        _audio.playSound(ChessSound.moveCheck);
      } else if (aiMove['captured'] != null) {
        _audio.playSound(ChessSound.capture);
      } else {
        _audio.playSound(ChessSound.moveSelf);
      }

      setState(() {
        _isAiThinking = false;
        _voiceFeedback = "AI played $san ($from to $to). Your turn!";
      });

      _checkGameOver();
    } else {
      setState(() {
        _isAiThinking = false;
      });
    }
  }

  Future<void> _showPromotionDialog(String from, String to) async {
    final chosenPiece = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PromotionDialog(),
    );

    if (chosenPiece != null) {
      _executeMove(from, to, promotion: chosenPiece.toLowerCase());
    }
  }

  bool _checkGameOver() {
    if (_game.game_over) {
      String title = "Game Finished";
      String message = "";
      String resultStr = "Completed";

      if (_game.in_checkmate) {
        final winner = _game.turn == chess_lib.Color.WHITE ? "Black" : "White";
        title = "Checkmate!";
        message = "$winner wins by checkmate.";
        resultStr = winner == "White" ? "1-0 (White Won)" : "0-1 (Black Won)";
        _audio.playSound(winner == "White" ? ChessSound.victory : ChessSound.defeat);
      } else if (_game.in_draw) {
        title = "Draw";
        message = "Game drawn by stalemate, repetition, or insufficient material.";
        resultStr = "½-½ (Draw)";
      }

      // Save to game history
      _history.saveGame(
        GameRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          gameMode: _gameMode.label,
          result: resultStr,
          movesCount: _game.history.length,
          movesSan: List<String>.from(_game.history.map((m) => m.move.san ?? '')),
          pgn: _game.pgn(),
        ),
      );

      _showGameOverDialog(title, message);
      return true;
    }
    return false;
  }

  void _showGameOverDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusColors.obsidian,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NexusColors.champagne, width: 2),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: NexusColors.champagne,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: NexusColors.ivory, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/history');
            },
            child: const Text('View History', style: TextStyle(color: NexusColors.mintAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusColors.emerald,
              foregroundColor: NexusColors.ivory,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _startNewGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _handleUndo() {
    if (_game.history.isEmpty) {
      setState(() {
        _voiceFeedback = "No moves to undo.";
      });
      return;
    }

    // In AI mode, undo both the AI's move and the user's move to return to user's turn
    if (_gameMode != GameMode.twoPlayer && _game.history.length >= 2) {
      _game.undo();
      _game.undo();
    } else {
      _game.undo();
    }

    _lastMoveFrom = null;
    _lastMoveTo = null;
    _syncBoardState();
    setState(() {
      _voiceFeedback = "Last move undone.";
    });
    HapticsService.trigger(HapticIntensity.selection);
  }

  void _startNewGame() {
    setState(() {
      _game.reset();
      _selectedSquare = null;
      _legalDestinations = [];
      _lastMoveFrom = null;
      _lastMoveTo = null;
      _checkSquare = null;
      _isAiThinking = false;
      _voiceFeedback = "New game started. White to move.";
      _syncBoardState();
    });
    HapticsService.trigger(HapticIntensity.medium);
  }

  // =========================================================================
  // BUILD UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final currentTurnColor = _game.turn == chess_lib.Color.WHITE ? PieceColor.white : PieceColor.black;
    final isWhiteTurn = currentTurnColor == PieceColor.white;

    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.obsidian,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: NexusColors.champagne, width: 1.5),
                color: NexusColors.emerald,
              ),
              child: const Icon(Icons.mic, color: NexusColors.champagne, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHESS NEXUS',
                  style: TextStyle(
                    color: NexusColors.ivory,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Voice-First Chess',
                  style: TextStyle(
                    color: NexusColors.mintAccent,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Game History',
            icon: const Icon(Icons.history, color: NexusColors.ivory),
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, color: NexusColors.ivory),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Game Mode & Turn Bar
            _buildModeAndTurnBar(isWhiteTurn),

            const SizedBox(height: 6),

            // 2. High Priority Voice Feedback Banner
            _buildVoiceFeedbackBanner(),

            const SizedBox(height: 8),

            // 3. Large Responsive Chessboard
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: NexusBoardWidget(
                    boardState: _boardState,
                    orientation: _playerColor,
                    selectedSquare: _selectedSquare,
                    legalMoveSquares: _legalDestinations,
                    lastMoveFrom: _lastMoveFrom,
                    lastMoveTo: _lastMoveTo,
                    checkSquare: _checkSquare,
                    onSquareSelected: _handleSquareSelected,
                    onMoveExecuted: (from, to) => _executeMove(from, to),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 4. Move Ribbon (Historical notation)
            MoveTapeRibbon(
              movesSan: _game.history.map((m) => m.move.san ?? '').toList(),
              currentMoveIndex: _game.history.length,
            ),

            const SizedBox(height: 8),

            // 5. Dedicated Voice & Action Controls Hub
            _buildVoiceControlsHub(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildModeAndTurnBar(bool isWhiteTurn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: NexusColors.deepForest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mode Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<GameMode>(
              value: _gameMode,
              dropdownColor: NexusColors.deepForest,
              style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.arrow_drop_down, color: NexusColors.champagne),
              items: GameMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(
                        mode == GameMode.voiceAi
                            ? Icons.mic
                            : (mode == GameMode.touchAi ? Icons.touch_app : Icons.people),
                        size: 16,
                        color: NexusColors.mintAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(mode.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => _gameMode = mode);
                  _startNewGame();
                }
              },
            ),
          ),

          // If vs AI, difficulty badge
          if (_gameMode != GameMode.twoPlayer)
            PopupMenuButton<AiDifficulty>(
              tooltip: 'Change Difficulty',
              color: NexusColors.deepForest,
              initialValue: _aiDifficulty,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.emerald),
                  color: NexusColors.obsidian,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 14, color: NexusColors.champagne),
                    const SizedBox(width: 4),
                    Text(
                      _aiDifficulty.name.toUpperCase(),
                      style: const TextStyle(color: NexusColors.champagne, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              itemBuilder: (ctx) => AiDifficulty.values.map((diff) {
                return PopupMenuItem(
                  value: diff,
                  child: Text(diff.displayName, style: const TextStyle(color: NexusColors.ivory, fontSize: 13)),
                );
              }).toList(),
              onSelected: (diff) => setState(() => _aiDifficulty = diff),
            ),

          // Turn Indicator Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isWhiteTurn ? Colors.white : Colors.black,
              border: Border.all(color: NexusColors.champagne, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isWhiteTurn ? Colors.black : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  isWhiteTurn ? 'WHITE' : 'BLACK',
                  style: TextStyle(
                    color: isWhiteTurn ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceFeedbackBanner() {
    Color borderColor = NexusColors.emerald;
    IconData statusIcon = Icons.record_voice_over;

    if (_voiceState == VoiceInteractionState.listening) {
      borderColor = NexusColors.mintAccent;
      statusIcon = Icons.mic;
    } else if (_voiceState == VoiceInteractionState.validating) {
      borderColor = NexusColors.champagne;
      statusIcon = Icons.hourglass_top;
    } else if (_voiceState == VoiceInteractionState.illegal || _voiceState == VoiceInteractionState.error) {
      borderColor = Colors.redAccent;
      statusIcon = Icons.error_outline;
    } else if (_voiceState == VoiceInteractionState.ambiguous) {
      borderColor = Colors.amberAccent;
      statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NexusColors.deepForest.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: borderColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _voiceFeedback,
              style: TextStyle(
                color: borderColor == Colors.redAccent ? Colors.redAccent : NexusColors.ivory,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControlsHub() {
    final isListening = _speech.isListening;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Action pills row (Hint, Legal Moves, Undo, Reset)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionChip(
                icon: Icons.lightbulb_outline,
                label: 'Hint',
                onTap: () => _handleSpokenCommand('suggest a move'),
              ),
              _buildActionChip(
                icon: Icons.list_alt,
                label: 'Moves',
                onTap: () => _handleSpokenCommand('what moves can i make'),
              ),
              _buildActionChip(
                icon: Icons.undo,
                label: 'Undo',
                onTap: _handleUndo,
              ),
              _buildActionChip(
                icon: Icons.refresh,
                label: 'New Game',
                onTap: _startNewGame,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Primary Voice Mic Button
          GestureDetector(
            onTap: _toggleVoiceListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: isListening
                          ? [NexusColors.emerald, NexusColors.mintAccent]
                          : [NexusColors.emerald, NexusColors.deepForest],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isListening ? NexusColors.mintAccent.withOpacity(0.4) : Colors.black45,
                        blurRadius: isListening ? 14 : 6,
                        spreadRadius: isListening ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: isListening ? NexusColors.obsidian : NexusColors.champagne,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isListening ? 'LISTENING... (TAP TO SEND)' : 'TAP TO SPEAK MOVE',
                        style: TextStyle(
                          color: isListening ? NexusColors.obsidian : NexusColors.ivory,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: NexusColors.deepForest,
          border: Border.all(color: NexusColors.emerald, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: NexusColors.mintAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: NexusColors.ivory, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
