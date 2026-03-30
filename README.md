# AuraNoise

AuraNoise is a Flutter ambient sound mixer app inspired by [Blanket](https://github.com/rafaelmardojai/blanket). It allows you to create immersive soundscapes by mixing multiple looping nature and ambient sounds, each with individual volume control. Built with Flutter for cross-platform support (Android, Linux, Windows, Web).

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.10+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

### Core Functionality

- **Ambient Sound Mixing**: Play multiple sounds simultaneously with individual volume controls
- **14 Built-in Sounds**: Carefully curated nature, travel, interior, and noise sounds
- **Custom Sounds**: Add your own audio files (OGG, MP3, WAV, AAC, FLAC, M4A, OPUS) via file picker
- **Presets**: Save and load different sound combinations with full state persistence
- **Global Volume**: Master volume control (0-100%) that multiplies individual sound volumes
- **Seamless Looping**: All sounds loop infinitely using `LoopMode.one`
- **Hide Inactive**: Option to hide sounds that aren't currently playing (per-preset setting)
- **Dark/Light Theme**: Material 3 design with dynamic theming (default: dark mode)

### Sound Library

Sounds are organized in 4 categories plus custom:

| Category | Sounds | Description |
|----------|--------|-------------|
| **Nature** (7) | rain, storm, wind, waves, stream, birds, summer-night | Natural environmental sounds |
| **Travel** (3) | train, boat, city | Transportation and urban ambience |
| **Interiors** (2) | coffee-shop, fireplace | Indoor atmospheric sounds |
| **Noise** (2) | pink-noise, white-noise | Synthetic noise for focus/sleep |
| **Custom** (∞) | User-defined | Your own audio files |

All built-in sounds are high-quality OGG files stored in `assets/sounds/`.

### UI Design

- **Responsive Grid Layout**: Automatically adjusts columns based on screen width (2-6 columns)
- **Compact Cards**: 140px minimum width, optimized for viewing many sounds at once
- **Large SVG Icons**: 56px vector icons for crisp rendering at any size
- **Minimalist Controls**: Volume sliders appear only when sound is playing
- **Quick Preset Navigation**: Dropdown selector with previous/next buttons
- **Options Menu**: Bottom sheet with all settings and actions

## Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      SoundMixerScreen                        │
│  ┌──────────────┐  ┌─────────────────────────────────────┐  │
│  │ Preset       │  │ VolumeControlPanel (collapsible)  │  │
│  │ Selector     │  └─────────────────────────────────────┘  │
│  └──────────────┘                                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    Sound Grid                            │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │ │
│  │  │ Nature   │ │ Nature   │ │ Travel   │ │Interiors │   │ │
│  │  │   🌧️    │ │   ⛈️    │ │   🚂    │ │   ☕     │   │ │
│  │  │  Rain    │ │  Storm   │ │  Train   │ │ Coffee   │   │ │
│  │  │ [━━━━━━] │ │ [━━━━━━] │ │ [━━━━━━] │ │ [━━━━━━] │   │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                      AudioService                            │
│  - Singleton managing all sound state                        │
│  - ChangeNotifier for reactive UI                          │
│  - Lazy AudioPlayer initialization                         │
│  - Preset management and persistence                        │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                      SettingsService                         │
│  - SharedPreferences wrapper                                 │
│  - Preset persistence                                        │
│  - Custom sound storage                                      │
└─────────────────────────────────────────────────────────────┘
```

### Entry Point

**`lib/main.dart`** initializes platform-specific audio backends:

```dart
// Desktop platforms (Linux/Windows) use media_kit
if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.windows)) {
  MediaKit.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
}

// Initialize settings and run app
await SettingsService().init();
runApp(const AuraNoiseApp());
```

### Models (`lib/models/`)

#### Sound (`sound.dart`)

Represents an ambient sound with lazy AudioPlayer initialization.

```dart
class Sound {
  final String name;          // Unique ID (e.g., 'rain')
  final String title;         // Display name (e.g., 'Rain')
  final String asset;         // Path to audio file
  final String category;      // Nature, Travel, Interiors, Noise, Custom
  final bool custom;          // User-added vs built-in

  // Lazy-initialized
  AudioPlayer? _player;
  double _volume = 0.0;       // 0.0 to 1.0
  bool _playing = false;
  bool _initialized = false;
}
```

**Key Feature: Lazy Initialization**
- AudioPlayer is `null` until first play
- `init()` creates player, loads asset, sets looping
- Prevents startup freeze with many sounds

#### Preset (`preset.dart`)

Represents a saved sound configuration.

```dart
class Preset {
  final String id;                    // Unique ID
  String name;                        // Display name
  final Map<String, double> volumes;  // Volume per sound
  final Map<String, bool> muted;       // Mute state per sound
  bool hideInactive;                 // Hide non-playing sounds
}
```

#### SoundGroups (`sound_groups.dart`)

Defines the 14 built-in sounds organized in 4 categories.

### Services (`lib/services/`)

#### AudioService (`audio_service.dart`)

**Singleton with ChangeNotifier** - Central state management.

**Key Responsibilities:**
- Sound lifecycle management (init, play, stop, dispose)
- Volume control (individual + global multiplication)
- Preset management (create, switch, rename, delete)
- Custom sound handling (add, remove)
- Background preloading of audio

**Initialization Flow:**
```
init()
├── Load settings (volume, active preset)
├── Create built-in sounds
├── Load custom sounds
├── Apply preset state (without audio init)
├── notifyListeners() → UI renders
└── _preloadSoundsInBackground() → Init audio
```

**Volume Formula:**
```
Final Volume = Sound Volume (0.0-1.0) × Global Volume (0.0-1.0)
```

#### SettingsService (`settings_service.dart`)

**Singleton wrapper for SharedPreferences.**

**Persistence Keys:**
- `global_volume` - Master volume
- `active_preset` - Current preset ID
- `presets` - List of all presets (JSON)
- `custom_sounds` - User-added sounds (JSON)
- `preset_volumes_$id` - Volumes for specific preset
- `preset_muted_$id` - Mute states for specific preset
- `hide_inactive_$id` - Hide inactive setting per preset
- `dark_mode` - Theme preference

### Screens (`lib/screens/`)

#### SoundMixerScreen (`sound_mixer_screen.dart`)

Main UI with lifecycle management.

**Features:**
- `WidgetsBindingObserver` for background state saving
- `LayoutBuilder` for responsive grid (2-6 columns)
- Animated `VolumeControlPanel` (shows/hides based on active sounds)
- Options menu with bottom sheet

**Grid Configuration:**
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: (constraints.maxWidth / 140).floor().clamp(2, 6),
  childAspectRatio: 0.9,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
)
```

### Widgets (`lib/widgets/`)

#### SoundItem (`sound_item.dart`)

Compact grid card with SVG icon.

**Design Specs:**
- Card padding: 12px
- Icon size: 56×56px (SVG with color filter)
- Title: 14px, bold when playing
- Volume slider: 24px height, appears when playing
- Elevation: 4 when playing, 1 when inactive

**Icon Resolution:**
- Built-in sounds: `assets/icons/{name}.svg`
- Custom sounds: `Icons.music_note` (Material icon fallback)

#### VolumeControlPanel (`volume_control_panel.dart`)

Shows active sounds with individual controls.

**Features:**
- List of playing sounds
- Volume slider per sound
- Mute/unmute button
- Remove button (stops sound)
- Animated height for smooth expand/collapse

#### PresetDialog / PresetSelector

- **PresetDialog**: Dialog for creating new presets
- **PresetSelector**: Dropdown with prev/next navigation buttons

#### AddSoundDialog (`add_sound_dialog.dart`)

File picker for custom sounds.

**Process:**
1. User selects file via `file_picker`
2. File copied to app documents directory (`sounds/`)
3. `Sound.custom()` created
4. Added to AudioService and persisted

## Audio Implementation

### Lazy Initialization

**Problem:** Creating 14+ AudioPlayer instances at startup freezes the UI for seconds.

**Solution:**
```dart
// Sound model
AudioPlayer? _player;  // null until first play

Future<void> init() async {
  if (_initialized) return;
  _player = AudioPlayer();
  await _player!.setAsset(asset);
  await _player!.setLoopMode(LoopMode.one);
  _initialized = true;
}
```

**Benefits:**
- UI renders immediately
- Audio initialized on-demand
- Background preloading for remaining sounds

### Platform Backends

**Android:**
- Backend: just_audio (ExoPlayer)
- Background playback: Supported

**Linux/Windows:**
- Backend: just_audio_media_kit (MPV)
- Initialization required:
  ```dart
  MediaKit.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
  ```
- Note: MPV may log lavf cache warnings (non-fatal)

**Web:**
- Backend: just_audio_web
- Limitations: Custom sounds may have browser storage restrictions

### Volume Control

**Three-Level Architecture:**

1. **Sound Volume** (0.0-1.0): Individual sound level, saved per preset
2. **Global Volume** (0.0-1.0): Master multiplier, affects all sounds
3. **Actual Volume**: Applied to AudioPlayer
   ```dart
   player.setVolume(sound.volume * globalVolume)
   ```

### Looping

All sounds use seamless looping:
```dart
await player.setLoopMode(LoopMode.one);
```

## Assets

### Audio Files

Located in `assets/sounds/`, format: OGG Vorbis

| File | Duration | Category | Description |
|------|----------|----------|-------------|
| rain.ogg | ~10s | Nature | Gentle rainfall |
| storm.ogg | ~10s | Nature | Thunder and rain |
| wind.ogg | ~10s | Nature | Wind blowing |
| waves.ogg | ~10s | Nature | Ocean waves |
| stream.ogg | ~10s | Nature | Flowing water |
| birds.ogg | ~10s | Nature | Bird songs |
| summer-night.ogg | ~10s | Nature | Crickets and night ambience |
| train.ogg | ~10s | Travel | Train passing |
| boat.ogg | ~10s | Travel | Boat/watercraft |
| city.ogg | ~10s | Travel | Urban ambience |
| coffee-shop.ogg | ~10s | Interiors | Cafe atmosphere |
| fireplace.ogg | ~10s | Interiors | Crackling fire |
| pink-noise.ogg | ~10s | Noise | Pink noise for focus |
| white-noise.ogg | ~10s | Noise | White noise for sleep |

### Icon Files

Located in `assets/icons/`, format: SVG

Each sound has a matching icon file:
- `rain.svg`, `storm.svg`, `wind.svg`, `waves.svg`, `stream.svg`, `birds.svg`
- `summer-night.svg`, `train.svg`, `boat.svg`, `city.svg`
- `coffee-shop.svg`, `fireplace.svg`, `pink-noise.svg`, `white-noise.svg`
- `sound-wave.svg` (generic), `add.svg` (UI element)

Icons rendered with `flutter_svg` and tinted with `ColorFilter`.

## Persistence

### What Gets Saved

**Per Preset:**
- Sound volumes (Map<String, double>)
- Playing/mute states (Map<String, bool>)
- hideInactive setting (bool)

**Global:**
- Global volume (double)
- Active preset ID (String)
- Preset list (List<Preset>)
- Custom sounds (List<Sound>)
- Dark mode preference (bool)

**Storage:**
- All data stored in SharedPreferences
- JSON encoding for complex objects
- Separate keys per preset: `preset_volumes_$id`, `preset_muted_$id`, `hide_inactive_$id`

### When Persistence Happens

1. Volume change
2. Sound toggle (play/stop)
3. Preset switch
4. App goes to background (`WidgetsBindingObserver`)

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4
- Android SDK (for Android builds)
- CMake (for Linux builds)
- Visual Studio (for Windows builds)

**For Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install mpv libmpv-dev

# Fedora
sudo dnf install mpv mpv-devel
```

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd auranoise

# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d linux
flutter run -d windows
flutter run -d android
flutter run -d chrome
```

### Building

```bash
# Android
flutter build apk                    # APK for side-loading
flutter build appbundle             # App Bundle for Play Store

# Desktop
flutter build linux                 # Linux binary
flutter build windows              # Windows executable

# Web
flutter build web                   # Web build (build/web/)
```

## Adding New Built-in Sounds

1. **Add audio file:**
   ```bash
   cp your-sound.ogg assets/sounds/new-sound.ogg
   ```

2. **Create icon:**
   ```bash
   # Create SVG icon matching the sound
   # Save to: assets/icons/new-sound.svg
   ```

3. **Update SoundGroups** (`lib/models/sound_groups.dart`):
   ```dart
   {
     'name': 'Nature',  // or existing category
     'sounds': [
       // ... existing sounds
       {'name': 'new-sound', 'title': 'New Sound'},
     ],
   }
   ```

4. **Register assets** (`pubspec.yaml`):
   ```yaml
   flutter:
     assets:
       - assets/sounds/new-sound.ogg
       - assets/icons/new-sound.svg
   ```

5. **Update documentation** (README.md, CLAUDE.md)

6. **Test:**
   ```bash
   flutter pub get
   flutter run
   ```

## Dependencies

| Package | Version | Purpose | Platform |
|---------|---------|---------|----------|
| `just_audio` | ^0.10.5 | Core audio playback | All |
| `just_audio_media_kit` | ^2.1.0 | Desktop audio backend | Linux, Windows |
| `media_kit_libs_linux` | any | Linux audio libraries | Linux |
| `media_kit_libs_windows_audio` | any | Windows audio libraries | Windows |
| `shared_preferences` | ^2.2.2 | Settings persistence | All |
| `file_picker` | ^8.0.0+1 | File selection for custom sounds | All |
| `path_provider` | ^2.1.2 | App documents directory | All |
| `flutter_svg` | ^2.0.10 | SVG icon rendering | All |
| `uuid` | ^4.4.0 | Unique preset IDs | All |
| `cupertino_icons` | ^1.0.8 | iOS-style icons | All |
| `flutter_lints` | ^6.0.0 | Lint rules | Dev |

## Platform Support

| Platform | Status | Backend | Notes |
|----------|--------|---------|-------|
| Android | ✅ Fully Supported | just_audio (ExoPlayer) | Background audio works |
| Linux | ✅ Fully Supported | just_audio_media_kit (MPV) | Requires media_kit libs |
| Windows | ✅ Fully Supported | just_audio_media_kit (MPV) | Requires media_kit libs |
| Web | ✅ Supported | just_audio_web | Custom sounds limited |
| iOS | ⚠️ Not tested | just_audio (AVPlayer) | Should work |
| macOS | ⚠️ Not tested | just_audio (AVPlayer) | Should work |

## Development Notes

### State Management Pattern

**Service-oriented with ChangeNotifier:**

```dart
// Service
class AudioService extends ChangeNotifier {
  void toggleSound(Sound sound) {
    sound.playing = !sound.playing;
    notifyListeners();  // Triggers UI rebuild
  }
}

// UI
class _SoundMixerScreenState extends State<SoundMixerScreen> {
  @override
  void initState() {
    _audioService.addListener(_onAudioServiceChanged);
  }

  void _onAudioServiceChanged() => setState(() {});
}
```

**Benefits:**
- Simple, no external packages
- Centralized state
- Reactive updates

### Performance Optimizations

1. **Lazy Audio Initialization:** AudioPlayers created only when first played
2. **Background Preloading:** Remaining sounds initialized after UI renders
3. **Efficient Grid:** LayoutBuilder calculates optimal columns
4. **SVG Icons:** Vector graphics scale without quality loss
5. **Minimal Rebuilds:** ChangeNotifier pattern targets specific listeners

### Theme Configuration

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    brightness: Brightness.dark,  // or .light
  ),
  useMaterial3: true,
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
)
```

### Debugging

Enable verbose logging:
```bash
flutter run --verbose
```

AudioService uses emoji-prefixed logs:
- 🎵 Audio operations
- ✓ Success
- ✗ Errors

### Common Issues

**Issue:** No audio on Linux/Windows
- **Fix:** Ensure MediaKit is initialized in main.dart

**Issue:** Custom sounds not persisting
- **Fix:** Check permissions, verify file picker returns valid path

**Issue:** Lavf cache warnings
- **Fix:** Non-fatal MPV warnings, can be ignored

**Issue:** UI freezes
- **Fix:** Shouldn't happen with lazy init; check for blocking operations

### Testing

```bash
# Run all tests
flutter test

# Run specific file
flutter test test/widget_test.dart

# Run with name filter
flutter test --name "SoundItem"

# Analyze code
flutter analyze

# Fix lint issues
flutter dart fix
```

## Project Structure

```
lib/
├── main.dart                      # Entry point
├── models/                        # Data models
│   ├── sound.dart                 # Sound with lazy AudioPlayer
│   ├── preset.dart                # Preset model
│   └── sound_groups.dart          # Built-in sound definitions
├── services/                      # Business logic
│   ├── audio_service.dart         # Audio and preset management
│   └── settings_service.dart      # SharedPreferences wrapper
├── screens/                       # Full-screen UI
│   └── sound_mixer_screen.dart    # Main UI
└── widgets/                       # Reusable components
    ├── sound_item.dart            # Sound card with SVG icon
    ├── volume_control_panel.dart  # Active sounds panel
    ├── preset_dialog.dart         # Create preset dialog
    ├── preset_selector.dart       # Preset dropdown
    └── add_sound_dialog.dart      # Add custom sound

assets/
├── sounds/                        # OGG audio files (14 sounds)
└── icons/                         # SVG icons (16 icons)

test/                              # Unit and widget tests
android/                           # Android-specific config
linux/                             # Linux-specific config
windows/                           # Windows-specific config
web/                               # Web-specific config
```

## Roadmap

- [ ] iOS/macOS testing and support
- [ ] Sleep timer (auto-stop after duration)
- [ ] Export/import presets
- [ ] Sound fade in/out transitions
- [ ] Audio visualization
- [ ] Keyboard shortcuts (desktop)
- [ ] System tray integration (desktop)
- [ ] More built-in sounds
- [ ] Sound packs/themes

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Blanket](https://github.com/rafaelmardojai/blanket) by Rafael Mardojai
- Audio playback powered by [just_audio](https://pub.dev/packages/just_audio)
- Desktop audio via [media_kit](https://github.com/media-kit/media-kit)
- SVG support by [flutter_svg](https://pub.dev/packages/flutter_svg)
- Sound icons designed for AuraNoise

---

**Made with Flutter** 💙
