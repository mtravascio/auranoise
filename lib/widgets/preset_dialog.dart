// Preset dialog for creating and managing presets
import 'package:flutter/material.dart';
import '../models/preset.dart';
import '../services/audio_service.dart';

class PresetDialog extends StatefulWidget {
  final AudioService audioService;

  const PresetDialog({
    super.key,
    required this.audioService,
  });

  @override
  State<PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<PresetDialog> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Preset'),
      content: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          labelText: 'Preset Name',
          hintText: 'Enter a name for this preset',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _textController.text.trim();
            if (name.isNotEmpty) {
              widget.audioService.addPreset(name);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// Preset selector widget
class PresetSelector extends StatelessWidget {
  final AudioService audioService;

  const PresetSelector({
    super.key,
    required this.audioService,
  });

  void _showPresetMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<Preset>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy + button.size.height,
      ),
      items: [
        for (final preset in audioService.presets)
          PopupMenuItem<Preset>(
            value: preset,
            child: Row(
              children: [
                if (preset.id == audioService.activePresetId)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(preset.name)),
                if (preset.id != 'default')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirm(context, preset);
                    },
                  ),
              ],
            ),
          ),
      ],
    ).then((selected) {
      if (selected != null) {
        audioService.setActivePreset(selected.id);
      }
    });
  }

  void _showDeleteConfirm(BuildContext context, Preset preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              audioService.removePreset(preset.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = audioService.activePreset;

    if (audioService.presets.length < 2) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 28),
          onPressed:
              audioService.canPrevPreset ? audioService.prevPreset : null,
          tooltip: 'Previous Preset',
        ),
        InkWell(
          onTap: () => _showPresetMenu(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  preset?.name ?? 'Default',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Icon(Icons.arrow_drop_down, size: 28),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 28),
          onPressed:
              audioService.canNextPreset ? audioService.nextPreset : null,
          tooltip: 'Next Preset',
        ),
      ],
    );
  }
}
