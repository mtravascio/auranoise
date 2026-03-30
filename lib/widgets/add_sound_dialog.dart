// Add custom sound dialog
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound.dart';
import '../services/audio_service.dart';

class AddSoundDialog extends StatefulWidget {
  final AudioService audioService;

  const AddSoundDialog({
    super.key,
    required this.audioService,
  });

  @override
  State<AddSoundDialog> createState() => _AddSoundDialogState();
}

class _AddSoundDialogState extends State<AddSoundDialog> {
  final _nameController = TextEditingController();
  String? _selectedFilePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          // Auto-fill name from filename if empty
          if (_nameController.text.isEmpty) {
            final fileName = result.files.single.name;
            _nameController.text =
                fileName.substring(0, fileName.lastIndexOf('.'));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _addSound() async {
    if (_nameController.text.trim().isEmpty || _selectedFilePath == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${appDir.path}/sounds');
      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }

      final fileName = _nameController.text.trim();
      final extension = _selectedFilePath!.split('.').last;
      final newPath = '${soundsDir.path}/$fileName.$extension';

      await File(_selectedFilePath!).copy(newPath);

      final sound = Sound.custom(
        name: fileName,
        uri: newPath,
      );

      await widget.audioService.addCustomSound(sound);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding sound: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Sound'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Sound Name',
                hintText: 'Enter a name for this sound',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.folder_open),
              label: Text(
                _selectedFilePath == null
                    ? 'Select Audio File'
                    : 'Change File',
              ),
            ),
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected: ${_selectedFilePath!.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _isLoading || _selectedFilePath == null ? null : _addSound,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
