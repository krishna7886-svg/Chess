import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';

class GameVaultScreen extends StatefulWidget {
  const GameVaultScreen({super.key});

  @override
  State<GameVaultScreen> createState() => _GameVaultScreenState();
}

class _GameVaultScreenState extends State<GameVaultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.deepForest,
        elevation: 0,
        title: const Text(
          'GAME VAULT & ARCHIVE',
          style: TextStyle(
            color: NexusColors.champagne,
            letterSpacing: 2.0,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: NexusColors.mintAccent),
            tooltip: 'Import PGN',
            onPressed: () => _showImportPgnDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: NexusColors.champagne),
            tooltip: 'Export Vault',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting 142 PGN games to NexusVault.pgn...'),
                  backgroundColor: NexusColors.deepForest,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: NexusColors.mintAccent,
          indicatorWeight: 3,
          labelColor: NexusColors.mintAccent,
          unselectedLabelColor: NexusColors.secondaryText,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
          tabs: const [
            Tab(text: 'MATCH ARCHIVE'),
            Tab(text: 'STUDY LINES'),
            Tab(text: 'SAVED POSITIONS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArchiveTab(context),
          _buildRepertoireTab(context),
          _buildSavedPositionsTab(context),
        ],
      ),
    );
  }

  Widget _buildArchiveTab(BuildContext context) {
    final archivedGames = [
      {
        'white': 'Alexander Vance (2280)',
        'black': 'KasparovBot-2600',
        'result': '1-0',
        'eco': 'B90',
        'opening': 'Sicilian Defence: Najdorf, English Attack',
        'date': '2026-11-12',
        'moves': 44,
        'accuracy': '94.2%',
        'timeControl': '10+0 Rapid',
      },
      {
        'white': 'Elena Rostova (2180)',
        'black': 'Alexander Vance (2280)',
        'result': '0-1',
        'eco': 'C88',
        'opening': 'Ruy Lopez: Closed, Chigorin Defence',
        'date': '2026-11-10',
        'moves': 58,
        'accuracy': '91.8%',
        'timeControl': '5+3 Blitz',
      },
      {
        'white': 'Alexander Vance (2280)',
        'black': 'Magnus-AI (2850)',
        'result': '1/2-1/2',
        'eco': 'D37',
        'opening': "Queen's Gambit Declined: Classical 5.Bf4",
        'date': '2026-11-08',
        'moves': 72,
        'accuracy': '97.5%',
        'timeControl': '15+10 Classical',
      },
      {
        'white': 'DarkHorse99 (2050)',
        'black': 'Alexander Vance (2280)',
        'result': '0-1',
        'eco': 'A40',
        'opening': "Queen's Pawn: Modern Defence",
        'date': '2026-11-05',
        'moves': 28,
        'accuracy': '88.4%',
        'timeControl': '3+0 Bullet',
      },
    ];

    return Column(
      children: [
        // Search & Filter Bar
        Container(
          padding: const EdgeInsets.all(12),
          color: NexusColors.deepForest.withOpacity(0.5),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: NexusColors.deepForest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NexusColors.emerald),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: NexusColors.ivory, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search player, ECO code or opening...',
                      hintStyle: TextStyle(color: NexusColors.secondaryText, fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: NexusColors.secondaryText, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NexusColors.emerald),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    dropdownColor: NexusColors.deepForest,
                    style: const TextStyle(color: NexusColors.mintAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.tune, color: NexusColors.mintAccent, size: 16),
                    items: ['All', 'Wins', 'Losses', 'Draws', 'Rapid', 'Blitz']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Games List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: archivedGames.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = archivedGames[index];
              final isWin = g['result'] == '1-0';
              final isDraw = g['result'] == '1/2-1/2';
              final resultColor = isWin ? NexusColors.mintAccent : (isDraw ? NexusColors.champagne : Colors.redAccent);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.emerald.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: resultColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: resultColor),
                              ),
                              child: Text(
                                g['result'] as String,
                                style: TextStyle(color: resultColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              g['timeControl'] as String,
                              style: const TextStyle(color: NexusColors.secondaryText, fontSize: 11),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: NexusColors.mintAccent, size: 14),
                            Text(
                              'Acc: ${g['accuracy']}',
                              style: const TextStyle(
                                color: NexusColors.mintAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '⚪ ${g['white']}',
                      style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '⚫ ${g['black']}',
                      style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '[${g['eco']}] ${g['opening']}',
                      style: const TextStyle(color: NexusColors.champagne, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${g['date']} • ${g['moves']} moves',
                          style: const TextStyle(color: NexusColors.secondaryText, fontSize: 10),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.analytics_outlined, size: 16, color: NexusColors.mintAccent),
                              label: const Text('ANALYSIS', style: TextStyle(color: NexusColors.mintAccent, fontSize: 11)),
                              onPressed: () => context.push('/analysis'),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.share_outlined, size: 16, color: NexusColors.champagne),
                              label: const Text('PGN', style: TextStyle(color: NexusColors.champagne, fontSize: 11)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PGN copied to clipboard!'),
                                    backgroundColor: NexusColors.deepForest,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRepertoireTab(BuildContext context) {
    final repertoires = [
      {'title': 'White Repertoire: 1.d4 Catalan System', 'lines': '34 variations', 'depth': 'Depth 18'},
      {'title': 'Black Repertoire: Sicilian Dragon Yugoslav', 'lines': '48 variations', 'depth': 'Depth 22'},
      {'title': 'Black Repertoire: King’s Indian Mar del Plata', 'lines': '29 variations', 'depth': 'Depth 20'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: repertoires.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = repertoires[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NexusColors.deepForest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.emerald),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book, color: NexusColors.champagne, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['title'] as String,
                      style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${r['lines']} • Stockfish ${r['depth']}',
                      style: const TextStyle(color: NexusColors.secondaryText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: NexusColors.mintAccent, size: 16),
                onPressed: () => context.push('/analysis'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedPositionsTab(BuildContext context) {
    final positions = [
      {'title': 'Lucena Position - Fundamental Rook Endgame', 'fen': '1K1k4/1P6/8/8/8/8/8/7R w - - 0 1', 'tag': 'Endgame'},
      {'title': 'Greek Gift Sacrifice on h7', 'fen': 'r1bq1rk1/ppp2ppp/2n1pn2/3p4/2PP4/2NBPN2/PP3PPP/R1BQK2R w KQ - 0 1', 'tag': 'Tactics'},
      {'title': 'Philidor Defence Pawn Push', 'fen': 'rnbqkbnr/ppp2ppp/3p4/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 3', 'tag': 'Opening'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: positions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = positions[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NexusColors.deepForest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.emerald),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p['title'] as String,
                    style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NexusColors.emerald,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p['tag'] as String,
                      style: const TextStyle(color: NexusColors.mintAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NexusColors.obsidian,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p['fen'] as String,
                  style: const TextStyle(
                    color: NexusColors.secondaryText,
                    fontSize: 10,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusColors.emerald,
                      foregroundColor: NexusColors.ivory,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('EXPLORE POSITION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => context.push('/analysis'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImportPgnDialog(BuildContext context) {
    final pgnController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NexusColors.deepForest,
        title: const Text('IMPORT PGN / FEN', style: TextStyle(color: NexusColors.champagne, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: pgnController,
          maxLines: 6,
          style: const TextStyle(color: NexusColors.ivory, fontSize: 12, fontFamily: 'RobotoMono'),
          decoration: const InputDecoration(
            hintText: 'Paste Portable Game Notation (PGN) or FEN string here...',
            hintStyle: TextStyle(color: NexusColors.secondaryText, fontSize: 11),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: NexusColors.secondaryText)),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NexusColors.mintAccent, foregroundColor: NexusColors.obsidian),
            child: const Text('IMPORT & VERIFY', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PGN parsed and saved to Vault successfully!'),
                  backgroundColor: NexusColors.deepForest,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

