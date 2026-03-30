// Preset Library Screen - GetX version with reactive state
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../models/preset.dart';
import '../theme/app_theme.dart';

class PresetLibraryScreen extends StatelessWidget {
  const PresetLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudioController.to;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AuraSpacing.xl,
              AuraSpacing.xxl + 60,
              AuraSpacing.xl,
              AuraSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preset Library',
                    style: AuraTypography.displaySmall,
                  ),
                  const SizedBox(height: AuraSpacing.sm),
                  Text(
                    'Your curated soundscapes. Tap play to activate a preset.',
                    style: AuraTypography.bodyLarge.copyWith(
                      color: AuraColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Preset list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xl),
            sliver: Obx(() => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    // Create new button as first item
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AuraSpacing.md),
                      child: _buildCreateNewButton(context, controller),
                    );
                  }
                  final presetIndex = index - 1;
                  if (presetIndex >= controller.presets.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AuraSpacing.md),
                    child: _buildPresetCard(controller, controller.presets[presetIndex]),
                  );
                },
                childCount: controller.presets.length + 1,
              ),
            )),
          ),
          // Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 120),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewButton(BuildContext context, AudioController controller) {
    return GestureDetector(
      onTap: () => _showCreatePresetDialog(controller),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          border: Border.all(
            color: AuraColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AuraColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AuraColors.primary,
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Text(
              'Create New Preset',
              style: AuraTypography.titleSmall.copyWith(
                color: AuraColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(AudioController controller, Preset preset) {
    return Obx(() {
      final isActive = preset.id == controller.activePresetId.value;
      final isPlaying = isActive && controller.isPlaying.value;
      final activeSoundsCount = controller.countActiveSoundsInPreset(preset);

      return Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: isActive
              ? AuraColors.surfaceContainer
              : AuraColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          border: Border.all(
            color: isActive
                ? AuraColors.primary.withValues(alpha: 0.3)
                : AuraColors.outlineVariant.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: () => _togglePreset(controller, preset),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isPlaying ? AuraColors.primaryGradient : null,
                  color: isPlaying ? null : AuraColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  boxShadow: isPlaying
                      ? [
                          BoxShadow(
                            color: AuraColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isPlaying ? Colors.white : AuraColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preset.name,
                          style: AuraTypography.titleSmall,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AuraColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AuraRadius.full),
                          ),
                          child: Text(
                            isPlaying ? 'NOW PLAYING' : 'SELECTED',
                            style: AuraTypography.labelSmall.copyWith(
                              color: AuraColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activeSoundsCount sounds',
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Actions menu
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AuraColors.onSurfaceVariant,
              ),
              color: AuraColors.surfaceContainerHighest,
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    _showRenameDialog(controller, preset);
                    break;
                  case 'delete':
                    if (preset.id != 'default') {
                      _showDeleteConfirm(controller, preset);
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('Rename', style: AuraTypography.bodyMedium),
                    ],
                  ),
                ),
                if (preset.id != 'default')
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 18, color: AuraColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: AuraTypography.bodyMedium.copyWith(
                            color: AuraColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _togglePreset(AudioController controller, Preset preset) {
    final isActive = preset.id == controller.activePresetId.value;

    if (isActive) {
      // If already active, toggle play/pause
      if (controller.isPlaying.value) {
        controller.stopAll();
      } else {
        // Resume playing by re-applying the preset
        controller.setActivePreset(preset.id);
      }
    } else {
      // Switch to this preset - save current first, then load new
      final prevPresetName = controller.activePreset?.name ?? 'Previous';
      controller.setActivePreset(preset.id);
      // Show feedback to user
      Get.snackbar(
        'Preset Switched',
        'Saved "$prevPresetName" and loaded "${preset.name}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AuraColors.surfaceContainerHighest,
        colorText: AuraColors.onSurface,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showCreatePresetDialog(AudioController controller) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AuraColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        title: Text('Create New Preset', style: AuraTypography.titleMedium),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Enter preset name',
            hintStyle: AuraTypography.bodyMedium.copyWith(
              color: AuraColors.onSurfaceVariant,
            ),
          ),
          style: AuraTypography.bodyMedium,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AuraTypography.labelLarge.copyWith(
                color: AuraColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                controller.addPreset(name);
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(AudioController controller, Preset preset) {
    final textController = TextEditingController(text: preset.name);

    Get.dialog(
      AlertDialog(
        backgroundColor: AuraColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        title: Text('Rename Preset', style: AuraTypography.titleMedium),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Preset name',
            hintStyle: AuraTypography.bodyMedium.copyWith(
              color: AuraColors.onSurfaceVariant,
            ),
          ),
          style: AuraTypography.bodyMedium,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AuraTypography.labelLarge.copyWith(
                color: AuraColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.renamePreset(preset.id, textController.text);
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(AudioController controller, Preset preset) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AuraColors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        title: Text('Delete Preset', style: AuraTypography.titleMedium),
        content: Text(
          'Are you sure you want to delete "${preset.name}"?',
          style: AuraTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AuraTypography.labelLarge.copyWith(
                color: AuraColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removePreset(preset.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuraColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
