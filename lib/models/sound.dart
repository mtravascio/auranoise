// Sound model representing an ambient sound
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class Sound {
  final String name;
  final String title;
  final String asset;
  final String category;
  final bool custom;
  AudioPlayer? _player;
  double _volume = 0.0;
  bool _playing = false;
  bool _initialized = false;

  Sound({
    required this.name,
    required this.title,
    required this.asset,
    required this.category,
    this.custom = false,
  });

  // Factory for built-in sounds
  factory Sound.builtin({
    required String name,
    required String title,
    required String category,
  }) {
    return Sound(
      name: name,
      title: title,
      asset: 'assets/sounds/$name.ogg',
      category: category,
      custom: false,
    );
  }

  // Factory for custom sounds
  factory Sound.custom({
    required String name,
    required String uri,
  }) {
    return Sound(
      name: name,
      title: name,
      asset: uri,
      category: 'Custom',
      custom: true,
    );
  }

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  double get volume => _volume;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _updatePlayerVolume();
  }

  bool get playing => _playing;
  set playing(bool value) {
    _playing = value;
    _updatePlayerVolume();
  }

  bool get initialized => _initialized;

  void _updatePlayerVolume() {
    if (_player != null) {
      final actualVolume = _playing ? _volume : 0.0;
      _player!.setVolume(actualVolume);
    }
  }

  /// Initialize the audio player. Called lazily when the sound is first played.
  Future<void> init() async {
    if (_initialized) return;

    try {
      if (custom) {
        await player.setFilePath(asset);
      } else {
        await player.setAsset(asset);
      }
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0);
      _initialized = true;
      debugPrint('✓ Sound initialized: $name');
    } catch (e, stackTrace) {
      debugPrint('✗ Error initializing sound $name: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _initialized = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'asset': asset,
      'category': category,
      'custom': custom,
      'volume': _volume,
      'playing': _playing,
    };
  }

  static Sound fromJson(Map<String, dynamic> json) {
    final sound = Sound(
      name: json['name'] as String,
      title: json['title'] as String,
      asset: json['asset'] as String,
      category: json['category'] as String,
      custom: json['custom'] as bool,
    );
    sound._volume = json['volume'] as double? ?? 0.0;
    sound._playing = json['playing'] as bool? ?? false;
    return sound;
  }
}