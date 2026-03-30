// Main sound mixer screen
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/add_sound_dialog.dart';
import '../widgets/preset_dialog.dart';
import '../widgets/sound_item.dart';
import '../widgets/volume_control_panel.dart';

class SoundMixerScreen extends StatefulWidget {
  const SoundMixerScreen({super.key});

  @override
  State<SoundMixerScreen> createState() => _SoundMixerScreenState();
}

class _SoundMixerScreenState extends State<SoundMixerScreen> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save state when app goes to background or is paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _audioService.saveState();
    }
  }

  Future<void> _initialize() async {
    try {
      await _audioService.init();
      _audioService.addListener(_onAudioServiceChanged);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('✗ Error initializing audio service: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to initialize audio: $e';
        });
      }
    }
  }

  void _onAudioServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showGlobalVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Global Volume'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _audioService.globalVolume > 0
                          ? Icons.volume_up
                          : Icons.volume_off,
                    ),
                    Expanded(
                      child: Slider(
                        value: _audioService.globalVolume,
                        onChanged: (value) {
                          _audioService.setGlobalVolume(value);
                          setState(() {});
                        },
                      ),
                    ),
                    Text(
                        '${(_audioService.globalVolume * 100).round()}%'),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Custom Sound'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AddSoundDialog(audioService: _audioService),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Save as Preset'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) =>
                      PresetDialog(audioService: _audioService),
                );
              },
            ),
            ListTile(
              leading: Icon(
                _audioService.hideInactive
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              title: const Text('Hide Inactive Sounds'),
              trailing: Switch(
                value: _audioService.hideInactive,
                onChanged: (value) => _audioService.setHideInactive(value),
              ),
              onTap: () => _audioService
                  .setHideInactive(!_audioService.hideInactive),
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset All Volumes'),
              onTap: () {
                Navigator.of(context).pop();
                _showResetConfirm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                _showSettingsDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Volumes'),
        content: const Text(
            'This will stop all sounds and reset all volumes to zero. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _audioService.resetVolumes();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Theme changes require app rebuild
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Start Paused'),
              subtitle: const Text('Start app with audio paused'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.headphones),
              title: const Text('Background Playback'),
              subtitle: const Text('Continue playing when minimized'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final sounds = _audioService.getSoundsByCategory(category);

    if (_audioService.hideInactive) {
      final visibleSounds = sounds.where((s) => s.playing).toList();
      if (visibleSounds.isEmpty) return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = (constraints.maxWidth / 140).floor().clamp(2, 6);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final sound = sounds[index];
                if (_audioService.hideInactive && !sound.playing) {
                  return const SizedBox.shrink();
                }
                return SoundItem(
                  sound: sound,
                  audioService: _audioService,
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AuraNoise')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _initialize();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AuraNoise'),
        centerTitle: true,
        actions: [
          // Preset selector
          PresetSelector(audioService: _audioService),
          // Global volume
          IconButton(
            icon: Icon(
              _audioService.globalVolume > 0
                  ? Icons.volume_up
                  : Icons.volume_off,
              size: 28,
            ),
            onPressed: _showGlobalVolumeDialog,
            tooltip: 'Global Volume',
          ),
          // Options menu
          IconButton(
            icon: const Icon(Icons.more_vert, size: 28),
            onPressed: _showOptionsMenu,
            tooltip: 'Options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active sounds volume panel
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _audioService.sounds.any((s) => s.playing)
                ? VolumeControlPanel(audioService: _audioService)
                : const SizedBox.shrink(),
          ),
          // Sound grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add custom sound button (as a grid item)
                  if (!_audioService.hideInactive)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) =>
                              AddSoundDialog(audioService: _audioService),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text('Add Custom Sound'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Categories
                  ..._audioService.categories
                      .map((category) => _buildCategorySection(category)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // No global play/pause button - each sound card controls its own playback
    );
  }
}
