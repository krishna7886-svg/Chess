import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/game_history_service.dart';

class GameVaultScreen extends StatefulWidget {
  const GameVaultScreen({super.key});

  @override
  State<GameVaultScreen> createState() => _GameVaultScreenState();
}

class _GameVaultScreenState extends State<GameVaultScreen> {
  final GameHistoryService _historyService = GameHistoryService();
  List<GameRecord> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final games = await _historyService.loadGames();
    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusColors.obsidian,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NexusColors.champagne),
        ),
        title: const Text('Clear History', style: TextStyle(color: NexusColors.champagne)),
        content: const Text('Are you sure you want to clear all previous game records?',
            style: TextStyle(color: NexusColors.ivory)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: NexusColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.clearHistory();
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.obsidian,
        elevation: 0,
        title: const Text(
          'Game History',
          style: TextStyle(
            color: NexusColors.ivory,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          if (_games.isNotEmpty)
            IconButton(
              tooltip: 'Clear History',
              icon: const Icon(Icons.delete_outline, color: NexusColors.secondaryText),
              onPressed: _clearHistory,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: NexusColors.mintAccent))
          : _games.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return _buildGameCard(game);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: NexusColors.secondaryText.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No Games Recorded Yet',
            style: TextStyle(
              color: NexusColors.ivory,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Play a game using Voice or Touch to save history.',
            style: TextStyle(color: NexusColors.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameRecord game) {
    final isWin = game.result.contains('Won');
    final formattedDate =
        '${game.date.year}-${game.date.month.toString().padLeft(2, '0')}-${game.date.day.toString().padLeft(2, '0')} ${game.date.hour.toString().padLeft(2, '0')}:${game.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWin ? NexusColors.champagne : NexusColors.emerald,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: NexusColors.emerald,
                ),
                child: Text(
                  game.gameMode,
                  style: const TextStyle(
                    color: NexusColors.mintAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(color: NexusColors.secondaryText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game.result,
                style: const TextStyle(
                  color: NexusColors.ivory,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${game.movesCount} moves',
                style: const TextStyle(color: NexusColors.champagne, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (game.movesSan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Moves: ${game.movesSan.take(8).join(' ')}${game.movesSan.length > 8 ? ' ...' : ''}',
              style: const TextStyle(color: NexusColors.secondaryText, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.copy, size: 14, color: NexusColors.mintAccent),
              label: const Text('Copy PGN', style: TextStyle(color: NexusColors.mintAccent, fontSize: 11)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: game.pgn));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PGN copied to clipboard!'),
                    backgroundColor: NexusColors.emerald,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
