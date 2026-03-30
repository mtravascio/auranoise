// GetX Audio Controller - Reactive state management for audio
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/sound.dart';
import '../models/preset.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';

class AudioController extends GetxController {
  static AudioController get to => Get.find();

  final AudioService _audioService = AudioService();
  final SettingsService _settings = SettingsService();

  // Expose audio service for widgets that need direct access
  AudioService get audioService => _audioService;

  // Observable variables
  final RxList<Sound> sounds = <Sound>[].obs;
  final RxList<Preset> presets = <Preset>[].obs;
  final RxString activePresetId = 'default'.obs;
  final RxDouble globalVolume = 1.0.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // Computed
  Preset? get activePreset {
    try {
      return presets.firstWhere((p) => p.id == activePresetId.value);
    } catch (_) {
      return presets.isNotEmpty ? presets.first : null;
    }
  }

  bool get canNextPreset {
    final index = presets.indexWhere((p) => p.id == activePresetId.value);
    return index >= 0 && index < presets.length - 1 && presets.length > 1;
  }

  bool get canPrevPreset {
    final index = presets.indexWhere((p) => p.id == activePresetId.value);
    return index > 0 && presets.length > 1;
  }

  List<Sound> get activeSounds => sounds
      .where((s) => s.playing && s.volume > 0)
      .toList();

  int get activeSoundsCount => activeSounds.length;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _audioService.init();

      // Sync with service
      sounds.assignAll(_audioService.sounds);
      presets.assignAll(_audioService.presets);
      activePresetId.value = _audioService.activePresetId;
      globalVolume.value = _audioService.globalVolume;
      isPlaying.value = _audioService.playing;

      // Listen to service changes
      _audioService.addListener(_onServiceChanged);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  void _onServiceChanged() {
    // Update observables when service changes
    sounds.refresh();
    presets.refresh();
    activePresetId.value = _audioService.activePresetId;
    globalVolume.value = _audioService.globalVolume;
    isPlaying.value = _audioService.playing;

    // Manage wake lock based on playing state
    _manageWakeLock();
  }

  void _manageWakeLock() {
    final wakeLockEnabled = _settings.getWakeLock();
    if (wakeLockEnabled && isPlaying.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  @override
  void onClose() {
    _audioService.removeListener(_onServiceChanged);
    super.onClose();
  }

  // Actions
  Future<void> toggleSound(Sound sound) async {
    await _audioService.toggleSound(sound);
    sounds.refresh();
    isPlaying.value = _audioService.playing;
  }

  Future<void> setSoundVolume(Sound sound, double volume) async {
    await _audioService.setSoundVolume(sound, volume);
    sounds.refresh();
    isPlaying.value = _audioService.playing;
  }

  Future<void> setGlobalVolume(double volume) async {
    await _audioService.setGlobalVolume(volume);
    globalVolume.value = _audioService.globalVolume;
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await stopAll();
    } else {
      // Resume current preset
      await _audioService.setActivePreset(activePresetId.value);
    }
    isPlaying.value = _audioService.playing;
  }

  Future<void> stopAll() async {
    await _audioService.stopAll();
    isPlaying.value = false;
    sounds.refresh();
  }

  Future<void> setActivePreset(String presetId) async {
    await _audioService.setActivePreset(presetId);
    activePresetId.value = _audioService.activePresetId;
    sounds.refresh();
    isPlaying.value = _audioService.playing;
  }

  Future<void> nextPreset() async {
    if (!canNextPreset) return;
    final index = presets.indexWhere((p) => p.id == activePresetId.value);
    if (index >= 0 && index < presets.length - 1) {
      await setActivePreset(presets[index + 1].id);
    }
  }

  Future<void> prevPreset() async {
    if (!canPrevPreset) return;
    final index = presets.indexWhere((p) => p.id == activePresetId.value);
    if (index > 0) {
      await setActivePreset(presets[index - 1].id);
    }
  }

  Future<void> addPreset(String name) async {
    await _audioService.addPreset(name);
    presets.assignAll(_audioService.presets);
    activePresetId.value = _audioService.activePresetId;
  }

  Future<void> removePreset(String presetId) async {
    await _audioService.removePreset(presetId);
    presets.assignAll(_audioService.presets);
    activePresetId.value = _audioService.activePresetId;
  }

  Future<void> renamePreset(String presetId, String newName) async {
    await _audioService.renamePreset(presetId, newName);
    presets.refresh();
  }

  List<Sound> getSoundsByCategory(String category) {
    return sounds.where((s) => s.category == category).toList();
  }

  List<String> get categories {
    final cats = sounds.map((s) => s.category).toSet().toList();
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

  int countActiveSoundsInPreset(Preset preset) {
    int count = 0;
    preset.volumes.forEach((soundName, volume) {
      final isMuted = preset.muted[soundName] ?? false;
      if (volume > 0 && !isMuted) {
        count++;
      }
    });
    return count;
  }
}
