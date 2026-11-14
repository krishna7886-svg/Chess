import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _voiceChessEnabled = true;
  String _language = 'English (US)';
  String _boardStyle = 'Nexus Emerald / Ivory';
  String _pieceSet = 'Preserved Classic High-Res';
  int _engineDepth = 18;
  bool _biometrics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.deepForest,
        elevation: 0,
        title: const Text(
          'NEXUS PREFERENCES',
          style: TextStyle(
            color: NexusColors.champagne,
            letterSpacing: 2.0,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Appearance & Board
          _buildSectionHeader('BOARD & APPEARANCE'),
          _buildCard([
            _buildDropdownTile(
              title: 'Board Palette Theme',
              subtitle: 'Active: $_boardStyle',
              icon: Icons.palette_outlined,
              value: _boardStyle,
              items: ['Nexus Emerald / Ivory', 'Obsidian Minimalist', 'Champagne Luxury', 'FIDE Tournament Green'],
              onChanged: (val) => setState(() => _boardStyle = val!),
            ),
            const Divider(color: NexusColors.emerald, height: 1),
            _buildDropdownTile(
              title: 'Chess Piece Vector Set',
              subtitle: 'Active: $_pieceSet',
              icon: Icons.extension_outlined,
              value: _pieceSet,
              items: ['Preserved Classic High-Res', 'Neo-Minimalist SVGs', 'Vintage Woodcraft'],
              onChanged: (val) => setState(() => _pieceSet = val!),
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Audio & Haptics
          _buildSectionHeader('SOUND & SENSORY HAPTICS'),
          _buildCard([
            SwitchListTile(
              activeColor: NexusColors.mintAccent,
              title: const Text('Move, Check & Capture Sounds', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Original acoustic sound effects (move, capture, castle, check)', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
              secondary: const Icon(Icons.volume_up_outlined, color: NexusColors.champagne),
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
            ),
            const Divider(color: NexusColors.emerald, height: 1),
            SwitchListTile(
              activeColor: NexusColors.mintAccent,
              title: const Text('Physical Haptic Vibrations', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Tactile response on piece drop and check state', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
              secondary: const Icon(Icons.vibration, color: NexusColors.champagne),
              value: _hapticsEnabled,
              onChanged: (val) => setState(() => _hapticsEnabled = val),
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Voice Chess & Bilingual Language
          _buildSectionHeader('VOICE CHESS & LOCALIZATION'),
          _buildCard([
            SwitchListTile(
              activeColor: NexusColors.mintAccent,
              title: const Text('Voice-Assisted Chess Input', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Speak moves aloud (e.g. "Knight f3", "రాజును తరలించండి")', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
              secondary: const Icon(Icons.mic_none_outlined, color: NexusColors.mintAccent),
              value: _voiceChessEnabled,
              onChanged: (val) => setState(() => _voiceChessEnabled = val),
            ),
            const Divider(color: NexusColors.emerald, height: 1),
            _buildDropdownTile(
              title: 'Primary Voice & Commentary Language',
              subtitle: 'Active: $_language',
              icon: Icons.language,
              value: _language,
              items: ['English (US)', 'English (UK)', 'Telugu (తెలుగు) Phonetic Engine'],
              onChanged: (val) => setState(() => _language = val!),
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Engine & Intelligence
          _buildSectionHeader('STOCKFISH ENGINE & GEMINI AI'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Engine Calculation Depth', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('$_engineDepth plies', style: const TextStyle(color: NexusColors.mintAccent, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'RobotoMono')),
                    ],
                  ),
                  Slider(
                    activeColor: NexusColors.mintAccent,
                    inactiveColor: NexusColors.emerald,
                    value: _engineDepth.toDouble(),
                    min: 8,
                    max: 26,
                    divisions: 9,
                    onChanged: (val) => setState(() => _engineDepth = val.round()),
                  ),
                ],
              ),
            ),
            const Divider(color: NexusColors.emerald, height: 1),
            ListTile(
              leading: const Icon(Icons.verified_outlined, color: NexusColors.champagne),
              title: const Text('Stockfish GPLv3 Compliance & Source', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Open-source UCI engine. Licensed under GNU GPLv3.', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
              trailing: const Icon(Icons.open_in_new, color: NexusColors.secondaryText, size: 16),
              onTap: () => _showLicenseDialog(context),
            ),
          ]),
          const SizedBox(height: 20),

          // Section: Security & Account
          _buildSectionHeader('SECURITY & SYSTEM'),
          _buildCard([
            SwitchListTile(
              activeColor: NexusColors.mintAccent,
              title: const Text('Biometric Authentication Lock', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Require Fingerprint / Face ID on app launch', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
              secondary: const Icon(Icons.fingerprint, color: NexusColors.champagne),
              value: _biometrics,
              onChanged: (val) => setState(() => _biometrics = val),
            ),
            const Divider(color: NexusColors.emerald, height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline, color: NexusColors.secondaryText),
              title: const Text('CHESS NEXUS Platform', style: TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Version 1.0.0 (Build 100) • Beyond the Board', style: TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: NexusColors.secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusColors.emerald.withOpacity(0.6)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: NexusColors.champagne),
      title: Text(title, style: const TextStyle(color: NexusColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: NexusColors.secondaryText, fontSize: 11)),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: NexusColors.deepForest,
          style: const TextStyle(color: NexusColors.mintAccent, fontSize: 12, fontWeight: FontWeight.bold),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusColors.deepForest,
        title: const Text('STOCKFISH ENGINE & LICENSING', style: TextStyle(color: NexusColors.champagne, fontSize: 15, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'CHESS NEXUS uses the Stockfish chess engine in compliance with the GNU General Public License v3 (GPLv3).\n\n'
            'Stockfish is a free, powerful UCI chess engine developed by Tord Romstad, Marco Costalba, Joona Kiiski, Gary Linscott, and the Stockfish development team.\n\n'
            'The engine source code and build instructions are fully available at https://github.com/official-stockfish/Stockfish in accordance with GPLv3 terms.',
            style: TextStyle(color: NexusColors.ivory, fontSize: 12, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NexusColors.mintAccent, foregroundColor: NexusColors.obsidian),
            child: const Text('UNDERSTOOD', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

