// Audio service managing all sounds and playback
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sound.dart';
import '../models/preset.dart';
import '../models/sound_groups.dart';
import 'settings_service.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final List<Sound> _sounds = [];
  final SettingsService _settings = SettingsService();
  double _globalVolume = 1.0;
  String _activePresetId = 'default';
  List<Preset> _presets = [];
  bool _isPreloading = false;
  int _preloadProgress = 0;

  // Background playback state
  bool _wasPlayingBeforeBackground = false;
  bool _isInBackground = false;

  List<Sound> get sounds => List.unmodifiable(_sounds);
  double get globalVolume => _globalVolume;
  // Playing state is determined by whether any sound is actively playing
  bool get playing => _sounds.any((s) => s.playing && s.volume > 0);
  String get activePresetId => _activePresetId;
  List<Preset> get presets => List.unmodifiable(_presets);
  bool get isPreloading => _isPreloading;
  int get preloadProgress => _preloadProgress;
  int get totalSounds => _sounds.length;

  Preset? get activePreset {
    try {
      return _presets.firstWhere((p) => p.id == _activePresetId);
    } catch (_) {
      return _presets.isNotEmpty ? _presets.first : null;
    }
  }

  bool get canNextPreset {
    final index = _presets.indexWhere((p) => p.id == _activePresetId);
    return index >= 0 && index < _presets.length - 1 && _presets.length > 1;
  }

  bool get canPrevPreset {
    final index = _presets.indexWhere((p) => p.id == _activePresetId);
    return index > 0 && _presets.length > 1;
  }

  Future<void> init() async {
    // Prevent double initialization
    if (_sounds.isNotEmpty) {
      debugPrint('🎵 AudioService: Already initialized, skipping...');
      return;
    }

    debugPrint('🎵 AudioService: Starting initialization...');

    // Load settings
    _globalVolume = _settings.volume;
    _activePresetId = _settings.activePresetId;
    debugPrint('🎵 AudioService: Settings loaded - globalVolume: $_globalVolume');

    // Initialize default presets if none exist
    _presets = _settings.getPresets();
    if (_presets.isEmpty) {
      _presets = [
        Preset(id: 'default', name: 'Default'),
      ];
      await _settings.savePresets(_presets);
    }

    // Ensure active preset ID is valid, fallback to default if not
    final presetExists = _presets.any((p) => p.id == _activePresetId);
    if (!presetExists) {
      debugPrint('🎵 Active preset $_activePresetId not found, falling back to default');
      _activePresetId = 'default';
      await _settings.setActivePreset('default');
    }

    // Clear any existing sounds first (safety)
    _sounds.clear();

    // Create built-in sounds
    final builtinSounds = SoundGroups.createDefaultSounds();
    _sounds.addAll(builtinSounds);
    debugPrint('🎵 AudioService: Created ${builtinSounds.length} built-in sounds');

    // Load custom sounds
    final customSounds = _settings.getCustomSounds();
    _sounds.addAll(customSounds);
    debugPrint('🎵 AudioService: Loaded ${customSounds.length} custom sounds');

    // Apply preset settings (without initializing sounds)
    _applyPresetState(_activePresetId);

    debugPrint('🎵 AudioService: Initialization complete - ${_sounds.length} sounds ready');
    notifyListeners();

    // Preload sounds in background (non-blocking)
    _preloadSoundsInBackground();
  }

  /// Preload all sounds in background without blocking UI
  /// Also starts playing any sounds that were active when app was closed
  Future<void> _preloadSoundsInBackground() async {
    if (_isPreloading) return;

    _isPreloading = true;
    _preloadProgress = 0;
    debugPrint('🎵 AudioService: Starting background preload...');

    // First, initialize all sounds (create a copy to avoid concurrent modification)
    final soundsToInit = List<Sound>.from(_sounds);
    for (final sound in soundsToInit) {
      if (!sound.initialized) {
        try {
          await sound.init();
          _preloadProgress++;
        } catch (e) {
          debugPrint('✗ Failed to preload ${sound.name}: $e');
        }
      }
    }
    notifyListeners();

    // Then, start playing active sounds (unless start_paused is enabled)
    final startPaused = _settings.getStartPaused();
    if (!startPaused) {
      final activeSounds = _sounds.where((s) => s.playing && s.volume > 0).toList();
      debugPrint('🎵 Active sounds to resume: ${activeSounds.length}');

      for (final sound in activeSounds) {
        try {
          if (sound.initialized) {
            await sound.player.setVolume(sound.volume * _globalVolume);
            await sound.player.play();
            debugPrint('🎵 Resumed playing: ${sound.name} (volume: ${sound.volume})');
            // Small delay to prevent audio buffer issues on Android
            await Future.delayed(const Duration(milliseconds: 50));
          }
        } catch (e) {
          debugPrint('✗ Failed to resume ${sound.name}: $e');
        }
      }
    } else {
      debugPrint('🎵 Start paused is enabled - not resuming sounds');
      // Reset playing state to false for all sounds
      for (final sound in _sounds) {
        if (sound.playing) {
          sound.playing = false;
        }
      }
    }

    _isPreloading = false;
    debugPrint('🎵 AudioService: Background preload complete');
    notifyListeners();
  }

  /// Apply preset state without initializing audio players
  void _applyPresetState(String presetId) {
    final volumes = _settings.getPresetVolumes(presetId);
    final muted = _settings.getPresetMuted(presetId);

    debugPrint('🎵 Applying preset state: $presetId');
    for (final sound in _sounds) {
      sound.volume = volumes[sound.name] ?? 0.0;
      sound.playing = !(muted[sound.name] ?? true);
      if (sound.playing && sound.volume > 0) {
        debugPrint('🎵 Active sound: ${sound.name} (volume: ${sound.volume})');
      }
    }
  }

  Future<void> _applyPreset(String presetId) async {
    final volumes = _settings.getPresetVolumes(presetId);
    final muted = _settings.getPresetMuted(presetId);

    for (final sound in _sounds) {
      sound.volume = volumes[sound.name] ?? 0.0;
      sound.playing = !(muted[sound.name] ?? true);

      // Apply global volume (initialize on-demand if needed)
      if (sound.playing && sound.volume > 0) {
        if (!sound.initialized) {
          await sound.init();
        }
        await sound.player.setVolume(sound.volume * _globalVolume);
        await sound.player.play();
      } else if (sound.initialized) {
        await sound.player.stop();
      }
    }
  }

  Future<void> setGlobalVolume(double volume) async {
    _globalVolume = volume.clamp(0.0, 1.0);
    await _settings.setVolume(_globalVolume);

    // Update all playing sounds that are initialized
    for (final sound in _sounds) {
      if (sound.playing && sound.initialized) {
        await sound.player.setVolume(sound.volume * _globalVolume);
      }
    }

    notifyListeners();
  }

  /// Stop all sounds
  Future<void> stopAll() async {
    debugPrint('🎵 stopAll() called');
    for (final sound in _sounds) {
      if (sound.initialized) {
        await sound.player.stop();
      }
    }
  }

  Future<void> setSoundVolume(Sound sound, double volume) async {
    final wasPlaying = sound.playing;
    sound.volume = volume;

    if (volume > 0 && !sound.playing) {
      sound.playing = true;
    }

    // Update UI immediately
    notifyListeners();

    if (sound.playing && sound.volume > 0) {
      if (!sound.initialized) {
        await sound.init();
      }
      await sound.player.setVolume(volume * _globalVolume);
      await sound.player.play();
    } else if (wasPlaying && volume == 0) {
      // Volume was set to 0, stop the sound
      if (sound.initialized) {
        await sound.player.stop();
      }
    }

    await _saveCurrentState();
  }

  Future<void> toggleSound(Sound sound) async {
    sound.playing = !sound.playing;

    // Set default volume if activating
    if (sound.playing && sound.volume == 0) {
      sound.volume = 0.5;
    }

    // Update UI immediately
    notifyListeners();

    debugPrint('🎵 toggleSound: ${sound.name}, playing=${sound.playing}');

    if (sound.playing && sound.volume > 0) {
      // User wants to play this sound
      if (!sound.initialized) {
        debugPrint('🎵 Initializing sound: ${sound.name}');
        await sound.init();
      }
      await sound.player.setVolume(sound.volume * _globalVolume);
      await sound.player.play();
      debugPrint('🎵 Sound ${sound.name} started playing');
    } else if (!sound.playing) {
      // User wants to stop this sound
      if (sound.initialized) {
        await sound.player.stop();
      }
      debugPrint('🎵 Sound ${sound.name} stopped');
    }

    await _saveCurrentState();
  }

  Future<void> _saveCurrentState() async {
    // Only save if there are active sounds, or if it's not the default preset
    // This prevents empty default preset from overwriting other presets' data
    final hasActiveSounds = _sounds.any((s) => s.volume > 0 || s.playing);
    if (hasActiveSounds || _activePresetId != 'default') {
      await _settings.saveSoundState(_activePresetId, _sounds);
      debugPrint('🎵 Saved state for preset: $_activePresetId');
    } else {
      debugPrint('🎵 Skipped saving empty default preset');
    }
  }

  /// Save current state (called when app goes to background)
  Future<void> saveState() async {
    await _saveCurrentState();
    debugPrint('🎵 State saved');
  }

  Future<void> resetVolumes() async {
    for (final sound in _sounds) {
      sound.volume = 0.0;
      sound.playing = false;
      if (sound.initialized) {
        await sound.player.stop();
      }
    }
    await _saveCurrentState();
    notifyListeners();
  }

  Future<void> setActivePreset(String presetId) async {
    // Save current state before switching
    await _saveCurrentState();

    // If switching FROM default preset and it has sounds, preserve its state
    if (_activePresetId == 'default') {
      final defaultHasSounds = _sounds.any((s) => s.volume > 0 || s.playing);
      if (defaultHasSounds) {
        await _settings.saveSoundState('default', _sounds);
        debugPrint('🎵 Preserved default preset state before switching');
      }
    }

    _activePresetId = presetId;
    await _settings.setActivePreset(presetId);
    await _applyPreset(presetId);

    notifyListeners();
  }

  Future<void> nextPreset() async {
    if (!canNextPreset) return;
    final index = _presets.indexWhere((p) => p.id == _activePresetId);
    if (index >= 0 && index < _presets.length - 1) {
      await setActivePreset(_presets[index + 1].id);
    }
  }

  Future<void> prevPreset() async {
    if (!canPrevPreset) return;
    final index = _presets.indexWhere((p) => p.id == _activePresetId);
    if (index > 0) {
      await setActivePreset(_presets[index - 1].id);
    }
  }

  Future<void> addPreset(String name) async {
    // First save current preset state before creating new one
    await _saveCurrentState();

    final preset = Preset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    // Copy current volumes to new preset
    for (final sound in _sounds) {
      preset.volumes[sound.name] = sound.volume;
      preset.muted[sound.name] = !sound.playing;
    }

    _presets.add(preset);
    await _settings.addPreset(preset);

    // Save the sound state for this preset so volumes are persisted
    await _settings.saveSoundState(preset.id, _sounds);

    // DO NOT automatically activate the new preset - let user decide
    // Just notify that presets list changed
    notifyListeners();
  }

  Future<void> removePreset(String presetId) async {
    if (presetId == 'default') return; // Can't remove default preset

    _presets.removeWhere((p) => p.id == presetId);
    await _settings.removePreset(presetId);

    if (_activePresetId == presetId) {
      await setActivePreset('default');
    }

    notifyListeners();
  }

  Future<void> renamePreset(String presetId, String newName) async {
    final preset = _presets.firstWhere((p) => p.id == presetId);
    preset.name = newName;
    await _settings.updatePreset(preset);
    notifyListeners();
  }

  Future<void> addCustomSound(Sound sound) async {
    await sound.init();
    _sounds.add(sound);
    await _settings.addCustomSound(sound);
    notifyListeners();
  }

  Future<void> removeCustomSound(Sound sound) async {
    sound.playing = false;
    if (sound.initialized) {
      await sound.player.stop();
    }
    await sound.dispose();
    _sounds.remove(sound);
    await _settings.removeCustomSound(sound.name);
    notifyListeners();
  }

  List<Sound> getSoundsByCategory(String category) {
    return _sounds.where((s) => s.category == category).toList();
  }

  List<String> get categories {
    final cats = _sounds.map((s) => s.category).toSet().toList();
    // Order categories
    const order = ['Nature', 'Travel', 'Interiors', 'Noise', 'Custom'];
    cats.sort((a, b) {
      final aIndex = order.indexOf(a);
      final bIndex = order.indexOf(b);
      if (aIndex >= 0 && bIndex >= 0) return aIndex.compareTo(bIndex);
      if (aIndex >= 0) return -1;
      if (bIndex >= 0) return 1;
      return a.compareTo(b);
    });
    return cats;
  }

  bool shouldShowSound(Sound sound) {
    final preset = activePreset;
    if (preset == null) return true;
    if (!preset.hideInactive) return true;
    return sound.playing;
  }

  Future<void> setHideInactive(bool value) async {
    final preset = activePreset;
    if (preset != null) {
      preset.hideInactive = value;
      await _settings.setPresetHideInactive(preset.id, value);
      notifyListeners();
    }
  }

  bool get hideInactive {
    return activePreset?.hideInactive ?? false;
  }

  /// Called when app goes to background
  Future<void> onAppBackground() async {
    _isInBackground = true;
    final backgroundPlayback = _settings.getBackgroundPlayback();

    debugPrint('🎵 App going to background - backgroundPlayback: $backgroundPlayback');

    if (!backgroundPlayback && playing) {
      // Save that we were playing before going to background
      _wasPlayingBeforeBackground = true;
      // Stop all sounds
      await stopAll();
      debugPrint('🎵 Stopped sounds (backgroundPlayback is OFF)');
    }
  }

  /// Called when app returns to foreground
  Future<void> onAppForeground() async {
    _isInBackground = false;
    final backgroundPlayback = _settings.getBackgroundPlayback();

    debugPrint('🎵 App returning to foreground - wasPlaying: $_wasPlayingBeforeBackground, backgroundPlayback: $backgroundPlayback');

    // If background playback was OFF and we were playing before, resume sounds
    if (!backgroundPlayback && _wasPlayingBeforeBackground) {
      _wasPlayingBeforeBackground = false;
      // Resume the active preset
      await _applyPreset(_activePresetId);
      debugPrint('🎵 Resumed sounds (returned from background)');
    }
  }

  @override
  void dispose() {
    // Save current state
    _saveCurrentState();
    _settings.setPlaying(playing);

    // Dispose all sounds
    for (final sound in _sounds) {
      sound.dispose();
    }
    _sounds.clear();
    super.dispose();
  }
}
