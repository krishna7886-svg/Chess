import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.deepForest,
        elevation: 0,
        title: const Text(
          'GRANDMASTER PROFILE',
          style: TextStyle(
            color: NexusColors.champagne,
            letterSpacing: 2.0,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: NexusColors.ivory),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            _buildPlayerHeaderCard(context),
            const SizedBox(height: 24),

            // Glicko-2 Ratings Grid
            const Text(
              'GLICKO-2 PERFORMANCE RATINGS',
              style: TextStyle(
                color: NexusColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildRatingsGrid(),
            const SizedBox(height: 24),

            // Performance & Style Radar Metrics
            const Text(
              'TACTICAL FINGERPRINT & STYLE',
              style: TextStyle(
                color: NexusColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildTacticalFingerprintCard(),
            const SizedBox(height: 24),

            // Achievements Shelf
            const Text(
              'TROPHY CABINET & MILESTONES',
              style: TextStyle(
                color: NexusColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildAchievementsShelf(),
            const SizedBox(height: 24),

            // Match History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT MATCH ENCOUNTERS',
                  style: TextStyle(
                    color: NexusColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/vault'),
                  child: const Text(
                    'VIEW ALL IN VAULT',
                    style: TextStyle(
                      color: NexusColors.mintAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentMatchesList(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusColors.emerald.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: NexusColors.champagne, width: 2.5),
                  color: NexusColors.emerald,
                ),
                child: const Center(
                  child: Icon(Icons.shield_outlined, color: NexusColors.champagne, size: 38),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NexusColors.champagne,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'IM',
                            style: TextStyle(
                              color: NexusColors.obsidian,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Alexander Vance',
                          style: TextStyle(
                            color: NexusColors.ivory,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '@avance_nexus • FIDE Master Track',
                      style: TextStyle(
                        color: NexusColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: NexusColors.mintAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Online • Ready for Battle',
                          style: TextStyle(
                            color: NexusColors.mintAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: NexusColors.emerald, thickness: 1),
          const SizedBox(height: 12),
          // Statistics Quick Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('TOTAL GAMES', '1,482'),
              _buildStatItem('WIN RATIO', '64.2%'),
              _buildStatItem('PEAK RATING', '2,340'),
              _buildStatItem('STREAK', '7 WINS'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: NexusColors.ivory,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: NexusColors.secondaryText,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsGrid() {
    final categories = [
      {'name': 'Rapid', 'rating': '2,280', 'rd': '±42', 'badge': '98.5%'},
      {'name': 'Blitz', 'rating': '2,120', 'rd': '±58', 'badge': '96.2%'},
      {'name': 'Bullet', 'rating': '1,945', 'rd': '±65', 'badge': '89.0%'},
      {'name': 'Tactics', 'rating': '2,450', 'rd': '±30', 'badge': '99.4%'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NexusColors.deepForest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.emerald.withOpacity(0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat['name']!.toUpperCase(),
                    style: const TextStyle(
                      color: NexusColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NexusColors.emerald,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TOP ${cat['badge']}',
                      style: const TextStyle(
                        color: NexusColors.mintAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    cat['rating']!,
                    style: const TextStyle(
                      color: NexusColors.champagne,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['rd']!,
                    style: TextStyle(
                      color: NexusColors.secondaryText.withOpacity(0.7),
                      fontSize: 11,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTacticalFingerprintCard() {
    final traits = [
      {'label': 'Tactical Aggression', 'value': 0.88, 'text': '88%'},
      {'label': 'Positional Solidity', 'value': 0.65, 'text': '65%'},
      {'label': 'Endgame Precision', 'value': 0.74, 'text': '74%'},
      {'label': 'Time Management', 'value': 0.82, 'text': '82%'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexusColors.emerald.withOpacity(0.7)),
      ),
      child: Column(
        children: traits.map((trait) {
          final val = trait['value'] as double;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trait['label'] as String,
                      style: const TextStyle(
                        color: NexusColors.ivory,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      trait['text'] as String,
                      style: const TextStyle(
                        color: NexusColors.mintAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: val,
                    backgroundColor: NexusColors.emerald.withOpacity(0.4),
                    valueColor: const AlwaysStoppedAnimation<Color>(NexusColors.mintAccent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsShelf() {
    final trophies = [
      {'title': 'Tactical Sniper', 'desc': 'Solved 100 puzzles with 100% accuracy', 'unlocked': true, 'icon': Icons.bolt},
      {'title': 'Master Hunter', 'desc': 'Defeated a 2200+ rated player', 'unlocked': true, 'icon': Icons.military_tech},
      {'title': 'Immortal Game', 'desc': 'Played a match with >95% Stockfish accuracy', 'unlocked': true, 'icon': Icons.star_border_purple500},
      {'title': 'Grandmaster Title', 'desc': 'Reach 2500 Glicko-2 rating', 'unlocked': false, 'icon': Icons.lock_outline},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trophies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final t = trophies[index];
          final unlocked = t['unlocked'] as bool;
          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NexusColors.deepForest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: unlocked ? NexusColors.champagne.withOpacity(0.7) : NexusColors.emerald.withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  t['icon'] as IconData,
                  color: unlocked ? NexusColors.champagne : NexusColors.secondaryText,
                  size: 26,
                ),
                const Spacer(),
                Text(
                  t['title'] as String,
                  style: TextStyle(
                    color: unlocked ? NexusColors.ivory : NexusColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked ? 'COMPLETED' : 'LOCKED',
                  style: TextStyle(
                    color: unlocked ? NexusColors.mintAccent : NexusColors.secondaryText.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentMatchesList(BuildContext context) {
    final matches = [
      {'opponent': 'Grandmaster_V', 'rating': '2295', 'result': 'VICTORY', 'color': NexusColors.mintAccent, 'moves': '42 moves', 'time': '10+0 Rapid', 'opening': "Queen's Gambit"},
      {'opponent': 'NexusAI-Grandmaster', 'rating': '2600', 'result': 'DRAW', 'color': NexusColors.champagne, 'moves': '68 moves', 'time': '3+2 Blitz', 'opening': "Sicilian Defence"},
      {'opponent': 'Elena_Rostova', 'rating': '2180', 'result': 'DEFEAT', 'color': Colors.redAccent, 'moves': '31 moves', 'time': '5+3 Blitz', 'opening': "Ruy Lopez"},
    ];

    return Column(
      children: matches.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexusColors.deepForest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.emerald.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (m['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: m['color'] as Color),
                ),
                child: Text(
                  m['result'] as String,
                  style: TextStyle(
                    color: m['color'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vs ${m['opponent']} (${m['rating']})',
                      style: const TextStyle(
                        color: NexusColors.ivory,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m['opening']} • ${m['moves']} • ${m['time']}',
                      style: const TextStyle(
                        color: NexusColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined, color: NexusColors.mintAccent, size: 20),
                onPressed: () => context.push('/analysis'),
                tooltip: 'Analyze Game',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

