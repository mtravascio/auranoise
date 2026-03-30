// Sound Mixer Dashboard - GetX version with reactive state
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../models/sound.dart';
import '../theme/app_theme.dart';
import '../widgets/add_sound_dialog.dart';
import '../widgets/preset_dialog.dart';
import 'active_mix_screen.dart';

class SoundMixerScreen extends StatelessWidget {
  const SoundMixerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.to;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(controller, context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AuraSpacing.xl),
                    ..._buildCategorySections(controller),
                    const SizedBox(height: 140),
                  ]),
                ),
              ),
            ],
          ),
          // Floating Active Mix Panel (mini player)
          if (controller.isPlaying.value)
            _buildMiniPlayer(controller),
        ],
      )),
    );
  }

  Widget _buildAppBar(AudioController controller, BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AuraColors.background.withValues(alpha: 0.9),
      elevation: 0,
      title: GestureDetector(
        onTap: () => _showPresetSelector(controller),
        child: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AuraColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AuraRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.activePreset?.name ?? 'Default',
                style: AuraTypography.titleSmall.copyWith(
                  color: AuraColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.expand_more,
                color: AuraColors.primary,
                size: 18,
              ),
            ],
          ),
        )),
      ),
      actions: [
        Obx(() => IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: controller.canPrevPreset
              ? () => controller.prevPreset()
              : null,
          color: controller.canPrevPreset
              ? AuraColors.primary
              : AuraColors.onSurfaceVariant.withValues(alpha: 0.4),
        )),
        Obx(() => IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: controller.canNextPreset
              ? () => controller.nextPreset()
              : null,
          color: controller.canNextPreset
              ? AuraColors.primary
              : AuraColors.onSurfaceVariant.withValues(alpha: 0.4),
        )),
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () => _showGlobalVolumeDialog(controller),
          color: AuraColors.primary,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsMenu(controller, context),
          color: AuraColors.primary,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildCategorySections(AudioController controller) {
    final categories = controller.categories;
    final List<Widget> sections = [];

    for (final category in categories) {
      final sounds = controller.getSoundsByCategory(category);
      if (sounds.isEmpty) continue;

      sections.add(_buildCategorySection(controller, category, sounds));
      sections.add(const SizedBox(height: AuraSpacing.xxl));
    }

    return sections;
  }

  Widget _buildCategorySection(
    AudioController controller,
    String category,
    List<Sound> sounds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              color: AuraColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: AuraTypography.titleMedium,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Divider(
                color: AuraColors.outlineVariant.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AuraSpacing.lg),
        // Sound grid with Obx for reactive updates
        Wrap(
          spacing: AuraSpacing.md,
          runSpacing: AuraSpacing.md,
          children: sounds.map((sound) {
            return _buildSoundCard(controller, sound);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSoundCard(AudioController controller, Sound sound) {
    final isPlaying = sound.playing && sound.volume > 0;

    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sound card
          GestureDetector(
            onTap: () => controller.toggleSound(sound),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: isPlaying ? AuraColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(AuraRadius.md),
                color: isPlaying ? null : AuraColors.surfaceContainer,
                boxShadow: isPlaying
                    ? [
                        BoxShadow(
                          color: AuraColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AuraColors.surfaceContainer.withValues(alpha: 0.95)
                      : AuraColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AuraRadius.md - 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getSoundIcon(sound.name),
                      size: 36,
                      color: isPlaying
                          ? Colors.white
                          : AuraColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sound.title,
                      style: AuraTypography.labelSmall.copyWith(
                        color: isPlaying
                            ? Colors.white
                            : AuraColors.onSurfaceVariant,
                        fontWeight:
                            isPlaying ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Volume slider (only when playing)
          if (isPlaying) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 24,
                child: Slider(
                  value: sound.volume,
                  onChanged: (value) => controller.setSoundVolume(sound, value),
                  activeColor: AuraColors.primary,
                  inactiveColor: AuraColors.surfaceVariant.withValues(alpha: 0.4),
                  thumbColor: AuraColors.primary,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(AudioController controller) {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () => Get.to(() => const ActiveMixScreen()),
        child: GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AuraColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AuraRadius.sm),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AuraColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.activePreset?.name ?? 'Custom Mix',
                      style: AuraTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${controller.activeSoundsCount} Active Layers',
                      style: AuraTypography.labelSmall.copyWith(
                        color: AuraColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                )),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause_circle),
                    onPressed: () => controller.stopAll(),
                    color: AuraColors.primary,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.audioService.resetVolumes(),
                    color: AuraColors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetSelector(AudioController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AuraColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        title: Text('Select Preset', style: AuraTypography.titleMedium),
        content: Obx(() => SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.presets.length,
            itemBuilder: (context, index) {
              final preset = controller.presets[index];
              final isActive = preset.id == controller.activePresetId.value;
              return ListTile(
                title: Text(preset.name, style: AuraTypography.bodyMedium),
                trailing: isActive
                    ? const Icon(Icons.check, color: AuraColors.primary)
                    : null,
                onTap: () {
                  controller.setActivePreset(preset.id);
                  Get.back();
                },
              );
            },
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

  void _showOptionsMenu(AudioController controller, BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AuraColors.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AuraRadius.lg),
            topRight: Radius.circular(AuraRadius.lg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AuraColors.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline,
                    color: AuraColors.primary),
                title: Text('Add Custom Sound',
                    style: AuraTypography.bodyMedium),
                onTap: () {
                  Get.back();
                  Get.dialog(AddSoundDialog(audioService: controller.audioService));
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add,
                    color: AuraColors.primary),
                title: Text('Save as Preset', style: AuraTypography.bodyMedium),
                onTap: () {
                  Get.back();
                  Get.dialog(PresetDialog(audioService: controller.audioService));
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt,
                    color: AuraColors.error),
                title: Text('Reset All Volumes', style: AuraTypography.bodyMedium),
                onTap: () {
                  Get.back();
                  controller.audioService.resetVolumes();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'nature':
        return Icons.forest;
      case 'travel':
        return Icons.commute;
      case 'interiors':
        return Icons.home;
      case 'noise':
        return Icons.graphic_eq;
      case 'custom':
        return Icons.upload;
      default:
        return Icons.category;
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
