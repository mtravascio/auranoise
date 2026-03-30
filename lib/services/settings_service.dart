// Settings service for persisting app state
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset.dart';
import '../models/sound.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Global volume
  double get volume => _prefs?.getDouble('global_volume') ?? 1.0;
  Future<void> setVolume(double value) async {
    await _prefs?.setDouble('global_volume', value);
  }

  // Playing state
  bool get playing => _prefs?.getBool('playing') ?? true;
  Future<void> setPlaying(bool value) async {
    await _prefs?.setBool('playing', value);
  }

  // Active preset
  String get activePresetId => _prefs?.getString('active_preset') ?? 'default';
  Future<void> setActivePreset(String id) async {
    await _prefs?.setString('active_preset', id);
  }

  // Presets
  List<Preset> getPresets() {
    final presetsJson = _prefs?.getStringList('presets') ?? [];
    return presetsJson.map((json) => Preset.fromJson(jsonDecode(json))).toList();
  }

  Future<void> savePresets(List<Preset> presets) async {
    final presetsJson = presets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs?.setStringList('presets', presetsJson);
  }

  Future<void> addPreset(Preset preset) async {
    final presets = getPresets();
    presets.add(preset);
    await savePresets(presets);
  }

  Future<void> removePreset(String id) async {
    final presets = getPresets();
    presets.removeWhere((p) => p.id == id);
    await savePresets(presets);
  }

  Future<void> updatePreset(Preset preset) async {
    final presets = getPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      presets[index] = preset;
      await savePresets(presets);
    }
  }

  // Custom sounds
  List<Sound> getCustomSounds() {
    final soundsJson = _prefs?.getStringList('custom_sounds') ?? [];
    return soundsJson.map((json) => Sound.fromJson(jsonDecode(json))).toList();
  }

  Future<void> addCustomSound(Sound sound) async {
    final sounds = getCustomSounds();
    sounds.add(sound);
    await saveCustomSounds(sounds);
  }

  Future<void> removeCustomSound(String name) async {
    final sounds = getCustomSounds();
    sounds.removeWhere((s) => s.name == name);
    await saveCustomSounds(sounds);
  }

  Future<void> saveCustomSounds(List<Sound> sounds) async {
    final soundsJson = sounds.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs?.setStringList('custom_sounds', soundsJson);
  }

  // Background playback
  bool get backgroundPlayback => _prefs?.getBool('background_playback') ?? true;
  Future<void> setBackgroundPlayback(bool value) async {
    await _prefs?.setBool('background_playback', value);
  }

  // Dark mode
  bool get darkMode => _prefs?.getBool('dark_mode') ?? true;
  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('dark_mode', value);
  }

  // Start paused
  bool get startPaused => _prefs?.getBool('start_paused') ?? false;
  Future<void> setStartPaused(bool value) async {
    await _prefs?.setBool('start_paused', value);
  }

  // Hide inactive
  bool getPresetHideInactive(String presetId) {
    return _prefs?.getBool('hide_inactive_$presetId') ?? false;
  }

  Future<void> setPresetHideInactive(String presetId, bool value) async {
    await _prefs?.setBool('hide_inactive_$presetId', value);
  }

  // Save sound state for current preset
  Future<void> saveSoundState(String presetId, List<Sound> sounds) async {
    final volumes = <String, double>{};
    final muted = <String, bool>{};
    for (final sound in sounds) {
      volumes[sound.name] = sound.volume;
      muted[sound.name] = !sound.playing;
    }
    await _prefs?.setString(
      'preset_volumes_$presetId',
      jsonEncode(volumes),
    );
    await _prefs?.setString(
      'preset_muted_$presetId',
      jsonEncode(muted),
    );
  }

  Map<String, double> getPresetVolumes(String presetId) {
    final json = _prefs?.getString('preset_volumes_$presetId');
    if (json != null) {
      return Map<String, double>.from(jsonDecode(json) as Map);
    }
    return {};
  }

  Map<String, bool> getPresetMuted(String presetId) {
    final json = _prefs?.getString('preset_muted_$presetId');
    if (json != null) {
      return Map<String, bool>.from(jsonDecode(json) as Map);
    }
    return {};
  }

  // Clear all data
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
