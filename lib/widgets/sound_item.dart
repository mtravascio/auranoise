// Sound item widget - displays a single sound in the grid
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/sound.dart';
import '../services/audio_service.dart';

class SoundItem extends StatelessWidget {
  final Sound sound;
  final AudioService audioService;

  const SoundItem({
    super.key,
    required this.sound,
    required this.audioService,
  });

  String? get _iconAsset {
    // Check if icon exists for this sound
    final iconPath = 'assets/icons/${sound.name}.svg';
    return sound.custom ? null : iconPath;
  }

  Widget _buildIcon(Color color) {
    final iconPath = _iconAsset;
    if (iconPath != null) {
      return SvgPicture.asset(
        iconPath,
        width: 56,
        height: 56,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    // Fallback icon for custom sounds
    return Icon(
      Icons.music_note,
      size: 56,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: sound.playing ? 4 : 1,
      color: sound.playing
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => audioService.toggleSound(sound),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(
                sound.playing
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                sound.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: sound.playing ? FontWeight.bold : FontWeight.normal,
                  color: sound.playing
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              if (sound.playing) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 24,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: sound.volume,
                      onChanged: (value) =>
                          audioService.setSoundVolume(sound, value),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
