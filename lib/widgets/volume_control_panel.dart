// Volume control panel for active sounds
import 'package:flutter/material.dart';
import '../models/sound.dart';
import '../services/audio_service.dart';

class VolumeControlPanel extends StatelessWidget {
  final AudioService audioService;

  const VolumeControlPanel({
    super.key,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final activeSounds = audioService.sounds
        .where((s) => s.playing)
        .toList();

    if (activeSounds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Sounds',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...activeSounds.map((sound) => _VolumeRow(
                  sound: sound,
                  audioService: audioService,
                )),
          ],
        ),
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final Sound sound;
  final AudioService audioService;

  const _VolumeRow({
    required this.sound,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            sound.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Slider(
            value: sound.volume,
            onChanged: (value) => audioService.setSoundVolume(sound, value),
          ),
        ),
        IconButton(
          icon: Icon(
            sound.volume > 0 ? Icons.volume_up : Icons.volume_off,
            size: 20,
          ),
          onPressed: () {
            if (sound.volume > 0) {
              audioService.setSoundVolume(sound, 0);
            } else {
              audioService.setSoundVolume(sound, 0.5);
            }
          },
          tooltip: sound.volume > 0 ? 'Mute' : 'Unmute',
        ),
        if (sound.custom)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () {
              audioService.removeCustomSound(sound);
            },
            tooltip: 'Remove',
          ),
      ],
    );
  }
}
