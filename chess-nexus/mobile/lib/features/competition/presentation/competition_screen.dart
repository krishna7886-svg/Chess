import 'package:flutter/material.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';

class CompetitionScreen extends StatelessWidget {
  const CompetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masters Tour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Grandmaster Circuit 2026", style: TextStyle(fontSize: 11, color: NexusColors.secondaryText)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NexusColors.champagne.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NexusColors.champagne),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, size: 14, color: NexusColors.champagne),
                SizedBox(width: 4),
                Text("Rank #142", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusColors.champagne)),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Featured Event Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NexusColors.emerald, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                  ],
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
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "LIVE NOW · 3m + 2s Blitz",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "\$25,000 USD Prize Pool",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Grandmaster Blitz Invitational · Round 4 of 7",
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NexusColors.ivory,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Board 1: GM Magnus Carlsen vs GM Hikaru Nakamura (Move 24 · Qh5)",
                      style: TextStyle(fontSize: 12, color: NexusColors.secondaryText),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye, color: NexusColors.obsidian),
                        label: const Text("SPECTATE LIVE (2,840 Watching)", style: TextStyle(color: NexusColors.obsidian)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NexusColors.mintAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Connecting to live Grandmaster broadcast...")),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Standings Section
              const Text(
                "LIVE STANDINGS (ROUND 4)",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: NexusColors.secondaryText),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildStandingsRow(1, "GM", "Magnus Carlsen", "🇳🇴", 2882, "3.5 / 4.0", 14.5, isTop: true),
                    const Divider(color: Colors.white10, height: 1),
                    _buildStandingsRow(2, "GM", "Hikaru Nakamura", "🇺🇸", 2875, "3.5 / 4.0", 13.8, isTop: true),
                    const Divider(color: Colors.white10, height: 1),
                    _buildStandingsRow(3, "GM", "Alireza Firouzja", "🇫🇷", 2811, "3.0 / 4.0", 12.2, isTop: true),
                    const Divider(color: Colors.white10, height: 1),
                    _buildStandingsRow(4, "GM", "Gukesh D", "🇮🇳", 2798, "3.0 / 4.0", 11.5),
                    const Divider(color: Colors.white10, height: 1),
                    _buildStandingsRow(5, "IM", "Nikolai Vance", "🇳🇴", 2045, "2.5 / 4.0", 9.0),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Upcoming Arena Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Midnight Bullet Arena (1+0)", style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.ivory)),
                        SizedBox(height: 2),
                        Text("Starts in 18m 42s · 482 Registered", style: TextStyle(fontSize: 11, color: NexusColors.secondaryText)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: NexusColors.emerald),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Successfully registered for Midnight Bullet Arena!")),
                        );
                      },
                      child: const Text("REGISTER"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsRow(
    int rank,
    String title,
    String name,
    String flag,
    int rating,
    String score,
    double sb, {
    bool isTop = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "#$rank",
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isTop ? NexusColors.champagne : NexusColors.secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: NexusColors.champagne.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "$flag $name",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NexusColors.ivory),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, color: NexusColors.mintAccent)),
              Text("${sb.toStringAsFixed(1)} SB", style: const TextStyle(fontSize: 10, color: NexusColors.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}

