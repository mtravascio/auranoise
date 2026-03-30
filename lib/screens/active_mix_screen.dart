// Active Mix Panel - GetX version with reactive state
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../models/sound.dart';
import '../theme/app_theme.dart';
import '../widgets/preset_dialog.dart';

class ActiveMixScreen extends StatelessWidget {
  const ActiveMixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.to;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final activeSounds = controller.activeSounds;

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                    color: AuraColors.primary,
                  ),
                  title: Text(
                    'Active Mix',
                    style: AuraTypography.headlineSmall,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _showGlobalVolumeDialog(controller),
                      color: AuraColors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AuraSpacing.lg),
                      // Header info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Mix',
                                style: AuraTypography.headlineLarge,
                              ),
                              const SizedBox(height: AuraSpacing.xs),
                              Text(
                                '${activeSounds.length} sounds currently blending',
                                style: AuraTypography.bodyMedium.copyWith(
                                  color: AuraColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          // Stop all button
                          ElevatedButton.icon(
                            onPressed: () => controller.stopAll(),
                            icon: const Icon(Icons.stop_circle, size: 20),
                            label: const Text('Stop All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AuraColors.surfaceContainerHighest,
                              foregroundColor: AuraColors.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AuraSpacing.xxl),
                      // Sound control list
                      ...activeSounds.map((sound) => _buildSoundControlRow(controller, sound)),
                      // Message when no sounds active
                      if (activeSounds.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AuraSpacing.xxl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.music_off,
                                  size: 64,
                                  color: AuraColors.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AuraSpacing.md),
                                Text(
                                  'No sounds active',
                                  style: AuraTypography.titleMedium.copyWith(
                                    color: AuraColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AuraSpacing.sm),
                                Text(
                                  'Tap sounds in the mixer to start blending',
                                  style: AuraTypography.bodyMedium.copyWith(
                                    color: AuraColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 200), // Space for bottom panel
                    ]),
                  ),
                ),
              ],
            ),
            // Global control section at bottom
            if (activeSounds.isNotEmpty) _buildGlobalControlPanel(controller),
          ],
        );
      }),
    );
  }

  Widget _buildSoundControlRow(AudioController controller, Sound sound) {
    final accentColor = _getSoundAccentColor(sound.category);

    return Obx(() {
      final currentSound = controller.sounds.firstWhere(
        (s) => s.name == sound.name,
        orElse: () => sound,
      );

      return Container(
        margin: const EdgeInsets.only(bottom: AuraSpacing.md),
        child: GlassPanel(
          padding: const EdgeInsets.all(AuraSpacing.lg),
          child: Row(
            children: [
              // Sound icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AuraRadius.sm),
                ),
                child: Icon(
                  _getSoundIcon(sound.name),
                  color: accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AuraSpacing.md),
              // Sound info and slider
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sound.title,
                          style: AuraTypography.titleSmall,
                        ),
                        Text(
                          sound.category,
                          style: AuraTypography.labelSmall.copyWith(
                            color: AuraColors.onSurfaceVariant,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AuraSpacing.md),
                    // Volume slider
                    Row(
                      children: [
                        Icon(
                          Icons.volume_mute,
                          size: 16,
                          color: AuraColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AuraSpacing.sm),
                        Expanded(
                          child: Slider(
                            value: currentSound.volume,
                            onChanged: (value) => controller.setSoundVolume(currentSound, value),
                            activeColor: AuraColors.primary,
                            inactiveColor: AuraColors.surfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: AuraSpacing.sm),
                        Icon(
                          Icons.volume_up,
                          size: 16,
                          color: AuraColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AuraSpacing.md),
              // Action buttons
              Column(
                children: [
                  // Mute button
                  IconButton(
                    icon: Icon(
                      currentSound.playing ? Icons.volume_off : Icons.volume_up,
                    ),
                    onPressed: () => controller.toggleSound(currentSound),
                    color: AuraColors.onSurfaceVariant,
                    splashRadius: 20,
                  ),
                  // Remove button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.setSoundVolume(currentSound, 0),
                    color: AuraColors.error,
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGlobalControlPanel(AudioController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AuraColors.background,
              AuraColors.background.withValues(alpha: 0.95),
              Colors.transparent,
            ],
          ),
        ),
        child: Obx(() => GlassPanel(
          padding: const EdgeInsets.all(AuraSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  // Master label
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Global Master',
                          style: AuraTypography.labelSmall.copyWith(
                            color: AuraColors.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mix Output',
                          style: AuraTypography.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  // Volume slider
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          color: AuraColors.onSurfaceVariant,
                        ),
                        Expanded(
                          child: Slider(
                            value: controller.globalVolume.value,
                            onChanged: (value) => controller.setGlobalVolume(value),
                            activeColor: AuraColors.primary,
                            inactiveColor: AuraColors.surfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        Icon(
                          Icons.volume_up,
                          color: AuraColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AuraSpacing.md),
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: AuraColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: AuraSpacing.md),
                  // Save preset button
                  ElevatedButton(
                    onPressed: () {
                      Get.dialog(PresetDialog(audioService: controller.audioService));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('SAVE PRESET'),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _showGlobalVolumeDialog(AudioController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AuraColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        title: Text('Global Volume', style: AuraTypography.titleMedium),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(controller.globalVolume.value * 100).round()}%',
              style: AuraTypography.headlineSmall.copyWith(
                color: AuraColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: controller.globalVolume.value,
              onChanged: (value) => controller.setGlobalVolume(value),
              activeColor: AuraColors.primary,
              inactiveColor: AuraColors.surfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Done',
              style: AuraTypography.labelLarge.copyWith(
                color: AuraColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSoundAccentColor(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
        return AuraColors.primary;
      case 'travel':
        return AuraColors.secondary;
      case 'interiors':
        return AuraColors.tertiary;
      case 'noise':
        return AuraColors.error;
      default:
        return AuraColors.primary;
    }
  }

  IconData _getSoundIcon(String soundName) {
    switch (soundName.toLowerCase()) {
      case 'rain':
        return Icons.water_drop;
      case 'storm':
        return Icons.thunderstorm;
      case 'wind':
        return Icons.air;
      case 'waves':
        return Icons.waves;
      case 'stream':
        return Icons.water;
      case 'birds':
        return Icons.flutter_dash;
      case 'summer-night':
        return Icons.nights_stay;
      case 'train':
        return Icons.train;
      case 'boat':
        return Icons.sailing;
      case 'city':
        return Icons.location_city;
      case 'coffee-shop':
        return Icons.coffee;
      case 'fireplace':
        return Icons.fireplace;
      case 'pink-noise':
        return Icons.circle;
      case 'white-noise':
        return Icons.circle_outlined;
      default:
        return Icons.music_note;
    }
  }
}
