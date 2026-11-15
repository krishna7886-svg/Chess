import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_nexus/app/theme/app_theme.dart';

class EditorialHomeScreen extends StatelessWidget {
  const EditorialHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: Avatar, Title, Rating, Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: NexusColors.champagne, width: 2),
                          color: NexusColors.deepForest,
                        ),
                        child: const Center(
                          child: Text("🤖", style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Grandmaster",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.ivory,
                            ),
                          ),
                          Text(
                            "Candidate Master Tier",
                            style: TextStyle(
                              fontSize: 11,
                              color: NexusColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Elo Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: NexusColors.champagne.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: NexusColors.champagne, width: 1),
                        ),
                        child: const Row(
                          children: [
                            Text("1850 ", style: TextStyle(fontWeight: FontWeight.bold, color: NexusColors.champagne)),
                            Icon(Icons.star, size: 14, color: NexusColors.champagne),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Streak Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orangeAccent, width: 1),
                        ),
                        child: const Row(
                          children: [
                            Text("7 ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                            Text("🔥", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Editorial Header
              const Text(
                "Beyond the Board",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: NexusColors.ivory,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Volume XXIV · The Art of Positional Mastery",
                style: TextStyle(
                  fontSize: 13,
                  color: NexusColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Daily Tactical Puzzle Hero Card
              Container(
                padding: const EdgeInsets.all(18),
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
                        const Text(
                          "DAILY TACTICAL PUZZLE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: NexusColors.mintAccent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: NexusColors.champagne.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Grandmaster · +14 Rating",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusColors.champagne),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "White to move and win material · Queen sacrifice deflection theme",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: NexusColors.ivory,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.bolt, color: NexusColors.obsidian),
                        label: const Text("SOLVE DAILY CHALLENGE", style: TextStyle(color: NexusColors.obsidian)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NexusColors.mintAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => context.go('/learn'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Quick Play Time Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "QUICK PAIR",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: NexusColors.secondaryText,
                    ),
                  ),
                  Text(
                    "● 14,820 Online",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NexusColors.mintAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeControlCard(
                      context,
                      title: "Bullet",
                      clock: "1 + 0",
                      icon: Icons.flash_on,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeControlCard(
                      context,
                      title: "Blitz",
                      clock: "3 + 2",
                      icon: Icons.local_fire_department,
                      color: Colors.orangeAccent,
                      isPopular: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTimeControlCard(
                      context,
                      title: "Rapid",
                      clock: "10 + 0",
                      icon: Icons.timer,
                      color: NexusColors.mintAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Continue Game Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NexusColors.deepForest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NexusColors.mintAccent),
                      ),
                      child: const Center(
                        child: Text("♟", style: TextStyle(fontSize: 28, color: NexusColors.ivory)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                "YOUR TURN · Move 24",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: NexusColors.mintAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "vs IM Nikolai Vance (2045)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NexusColors.ivory,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexusColors.emerald,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => context.go('/play'),
                      child: const Text("RESUME"),
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

  Widget _buildTimeControlCard(
    BuildContext context, {
    required String title,
    required String clock,
    required IconData icon,
    required Color color,
    bool isPopular = false,
  }) {
    return InkWell(
      onTap: () => context.go('/play'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isPopular ? NexusColors.emerald.withOpacity(0.5) : NexusColors.deepForest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPopular ? NexusColors.mintAccent : Colors.white12,
            width: isPopular ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              clock,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: NexusColors.ivory,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: NexusColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

