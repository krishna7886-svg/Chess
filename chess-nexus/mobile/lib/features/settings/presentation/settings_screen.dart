import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/speech_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audio = AudioService();
  final SpeechService _speech = SpeechService();

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  String _boardTheme = "Obsidian & Emerald";

  @override
  void initState() {
    super.initState();
    _soundEnabled = _audio.isSoundEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.obsidian,
      appBar: AppBar(
        backgroundColor: NexusColors.obsidian,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: NexusColors.ivory,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Voice Recognition Section
          _buildSectionHeader('VOICE CONTROL'),
          _buildVoiceCard(),

          const SizedBox(height: 20),

          // 2. Audio & Haptics Section
          _buildSectionHeader('AUDIO & HAPTICS'),
          _buildAudioCard(),

          const SizedBox(height: 20),

          // 3. Board Aesthetics Section
          _buildSectionHeader('BOARD APPEARANCE'),
          _buildAppearanceCard(),

          const SizedBox(height: 20),

          // 4. Voice Commands Guide Section
          _buildSectionHeader('SPOKEN COMMANDS GUIDE'),
          _buildVoiceGuideCard(),

          const SizedBox(height: 24),

          // 5. About
          Center(
            child: Column(
              children: [
                Text(
                  'CHESS NEXUS',
                  style: TextStyle(
                    color: NexusColors.champagne.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Beyond the Board — Voice-First Chess\nVersion 1.0.0 (Release Build)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: NexusColors.secondaryText, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          color: NexusColors.mintAccent,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildVoiceCard() {
    final hasPerm = _speech.hasPermission;

    return Container(
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusColors.emerald, width: 1.2),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              hasPerm ? Icons.mic : Icons.mic_off,
              color: hasPerm ? NexusColors.mintAccent : Colors.redAccent,
            ),
            title: const Text('Microphone Permission', style: TextStyle(color: NexusColors.ivory, fontSize: 14)),
            subtitle: Text(
              hasPerm ? 'Active & Ready for Voice Moves' : 'Permission Required for Speech',
              style: TextStyle(
                color: hasPerm ? NexusColors.mintAccent : NexusColors.secondaryText,
                fontSize: 12,
              ),
            ),
            trailing: hasPerm
                ? const Icon(Icons.check_circle, color: NexusColors.mintAccent, size: 20)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusColors.emerald,
                      foregroundColor: NexusColors.ivory,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    onPressed: () async {
                      await _speech.initialize();
                      setState(() {});
                    },
                    child: const Text('Grant', style: TextStyle(fontSize: 12)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard() {
    return Container(
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusColors.emerald, width: 1.2),
      ),
      child: Column(
        children: [
          SwitchListTile(
            activeColor: NexusColors.mintAccent,
            title: const Text('Sound Effects', style: TextStyle(color: NexusColors.ivory, fontSize: 14)),
            subtitle: const Text('Play sound on moves, captures, and checks',
                style: TextStyle(color: NexusColors.secondaryText, fontSize: 12)),
            value: _soundEnabled,
            onChanged: (val) {
              setState(() {
                _soundEnabled = val;
                _audio.toggleSound(val);
              });
              if (val) _audio.playSound(ChessSound.moveSelf);
            },
          ),
          const Divider(color: NexusColors.emerald, height: 1),
          SwitchListTile(
            activeColor: NexusColors.mintAccent,
            title: const Text('Haptic Feedback', style: TextStyle(color: NexusColors.ivory, fontSize: 14)),
            subtitle: const Text('Vibrate gently when pieces move or check occurs',
                style: TextStyle(color: NexusColors.secondaryText, fontSize: 12)),
            value: _hapticsEnabled,
            onChanged: (val) {
              setState(() => _hapticsEnabled = val);
              if (val) HapticsService.vibrateOnMove();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusColors.emerald, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Board Palette', style: TextStyle(color: NexusColors.ivory, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _boardTheme,
            dropdownColor: NexusColors.deepForest,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: NexusColors.emerald),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: NexusColors.emerald),
              ),
            ),
            style: const TextStyle(color: NexusColors.ivory, fontSize: 13),
            items: const [
              DropdownMenuItem(value: "Obsidian & Emerald", child: Text("Obsidian & Emerald (Signature Dark)")),
              DropdownMenuItem(value: "Deep Forest & Ivory", child: Text("Deep Forest & Ivory (Classic)")),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _boardTheme = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceGuideCard() {
    const examples = [
      {'command': 'Move pawn to E4', 'desc': 'Standard pawn opening'},
      {'command': 'Knight to F3', 'desc': 'Natural piece development'},
      {'command': 'Bishop takes C4', 'desc': 'Tactical capture'},
      {'command': 'Castle kingside', 'desc': 'Executes O-O castling'},
      {'command': 'Castle queenside', 'desc': 'Executes O-O-O castling'},
      {'command': 'Undo', 'desc': 'Reverts the previous turn'},
      {'command': 'Restart game', 'desc': 'Starts a clean new board'},
      {'command': 'What moves can I make?', 'desc': 'Announces and highlights all legal moves'},
      {'command': 'Suggest a move', 'desc': 'Offers an AI tactical recommendation'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexusColors.deepForest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusColors.champagne, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mic, size: 16, color: NexusColors.champagne),
              SizedBox(width: 8),
              Text(
                'Supported Voice Commands',
                style: TextStyle(color: NexusColors.champagne, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...examples.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: NexusColors.mintAccent, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '"${ex['command']}" — ',
                              style: const TextStyle(
                                color: NexusColors.ivory,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ex['desc'],
                              style: const TextStyle(
                                color: NexusColors.secondaryText,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
