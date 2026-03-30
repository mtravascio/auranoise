# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AuraNoise is a Flutter ambient sound mixer app inspired by [Blanket](https://github.com/rafaelmardojai/blanket). It allows users to create immersive soundscapes by mixing multiple looping nature and ambient sounds, each with individual volume control. The app uses `just_audio` for cross-platform audio playback, `flutter_svg` for vector icons, and `shared_preferences` for settings persistence.

## Common Commands

```bash
# Run the app (defaults to available device, use -d for specific device)
flutter run

# Run on a specific device
flutter run -d linux
flutter run -d chrome
flutter run -d android

# Build for release
flutter build apk                    # Android APK
flutter build appbundle             # Android App Bundle
flutter build web                   # Web
flutter build linux                 # Linux desktop
flutter build windows              # Windows desktop

# Run tests
flutter test
flutter test test/widget_test.dart  # Run specific test file
flutter test --name "Test Name"    # Run specific test by name

# Analyze and lint
flutter analyze
flutter dart fix                    # Auto-fix lint issues

# Dependency management
flutter pub get
flutter pub upgrade
flutter pub outdated

# Clean build artifacts
flutter clean
```

## Project Structure

```
lib/
├── main.dart                      # Entry point - initializes platform backends and app theme
├── models/                        # Data models
│   ├── sound.dart                 # Sound model with lazy AudioPlayer initialization
│   ├── preset.dart                # Preset model for saved sound combinations
│   └── sound_groups.dart          # Built-in sound definitions and categories
├── services/                      # Business logic and state management
│   ├── audio_service.dart         # Singleton managing audio, presets, persistence
│   └── settings_service.dart      # SharedPreferences wrapper for settings
├── screens/                       # Full-screen UI
│   └── sound_mixer_screen.dart    # Main UI with sound grid and controls
└── widgets/                       # Reusable UI components
    ├── sound_item.dart            # Compact grid card with SVG icon and volume slider
    ├── volume_control_panel.dart  # Panel for active sounds with sliders
    ├── preset_dialog.dart         # Dialog for creating new presets
    ├── preset_selector.dart       # Dropdown and navigation for presets
    └── add_sound_dialog.dart      # File picker for custom sounds

assets/
├── sounds/                        # OGG audio files (14 built-in sounds)
└── icons/                         # SVG icon files for each sound
```

## Architecture

### Entry Point

**`lib/main.dart`** - Application bootstrap:
- `WidgetsFlutterBinding.ensureInitialized()` for async initialization
- Conditional media_kit initialization (Linux/Windows only):
  ```dart
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows)) {
    MediaKit.ensureInitialized();
    JustAudioMediaKit.ensureInitialized();
  }
  ```
- `SettingsService().init()` before `runApp()`
- Material 3 theming with `ColorScheme.fromSeed(seedColor: Colors.blueGrey)`
- Theme switching based on `SettingsService.darkMode`

### Models (`lib/models/`)

#### Sound (`sound.dart`)
Represents an ambient sound with lazy AudioPlayer initialization.

**Properties:**
- `name: String` - Unique identifier (e.g., 'rain', 'birds')
- `title: String` - Display name (e.g., 'Rain', 'Birds')
- `asset: String` - Path to audio file (assets/sounds/*.ogg or file path for custom)
- `category: String` - Category name (Nature, Travel, Interiors, Noise, Custom)
- `custom: bool` - True for user-added sounds
- `_player: AudioPlayer?` - Lazy-initialized audio player
- `_volume: double` - 0.0 to 1.0
- `_playing: bool` - Whether sound should be playing
- `_initialized: bool` - Whether AudioPlayer has been created

**Factories:**
- `Sound.builtin({name, title, category})` - Creates built-in sound with auto-generated asset path
- `Sound.custom({name, uri})` - Creates custom sound from file URI

**Key Methods:**
- `init()` - Lazy initialization: creates AudioPlayer, sets asset/file path, configures LoopMode.one, sets volume to 0
- `_updatePlayerVolume()` - Applies `actualVolume = _playing ? _volume : 0.0` to player
- `dispose()` - Cleans up AudioPlayer resources

**Volume Formula:**
Final volume = `soundVolume * globalVolume` (applied in AudioService)

#### Preset (`preset.dart`)
Represents a saved sound configuration.

**Properties:**
- `id: String` - Unique identifier (timestamp for user presets, 'default' for default)
- `name: String` - Display name
- `volumes: Map<String, double>` - Volume per sound name
- `muted: Map<String, bool>` - Mute state per sound name
- `hideInactive: bool` - Whether to hide inactive sounds in this preset

**Methods:**
- `toJson() / fromJson()` - Serialization for SharedPreferences
- `copy()` - Deep copy for editing

#### SoundGroups (`sound_groups.dart`)
Defines built-in sound categories and their sounds.

**Categories (in order):**
1. **Nature** (7 sounds): rain, storm, wind, waves, stream, birds, summer-night
2. **Travel** (3 sounds): train, boat, city
3. **Interiors** (2 sounds): coffee-shop, fireplace
4. **Noise** (2 sounds): pink-noise, white-noise

**Methods:**
- `createDefaultSounds()` - Returns List<Sound> for all built-in sounds
- `getCategoryForSound(name)` - Returns category for a sound name

### Services (`lib/services/`)

#### AudioService (`audio_service.dart`)
**Singleton pattern with ChangeNotifier for reactive UI.**

**State Properties:**
- `_sounds: List<Sound>` - All sounds (built-in + custom)
- `_globalVolume: double` - 0.0 to 1.0, affects all sounds
- `_activePresetId: String` - Currently active preset
- `_presets: List<Preset>` - All saved presets
- `_isPreloading: bool` - Background preload status
- `_preloadProgress: int` - Sounds preloaded so far

**Computed Properties:**
- `playing: bool` - True if any sound is playing with volume > 0
- `canNextPreset / canPrevPreset` - Navigation bounds checking
- `activePreset: Preset?` - Current preset or null

**Initialization Flow (`init()`):**
1. Load global volume and active preset from SettingsService
2. Load or create default presets
3. Create built-in sounds from SoundGroups
4. Load custom sounds from SettingsService
5. Apply preset state (volumes, playing states) without initializing audio
6. Notify listeners (UI can render)
7. `_preloadSoundsInBackground()` - Non-blocking audio initialization

**Background Preloading (`_preloadSoundsInBackground()`):**
- Initializes each Sound's AudioPlayer via `sound.init()`
- Updates `_preloadProgress` for progress indication
- After initialization, resumes playing any sounds that were active
- Adds 50ms delay between sounds to prevent Android audio buffer issues

**Preset Management:**
- `setActivePreset(id)` - Saves current state, switches preset, applies new state
- `_applyPreset(id)` - Applies volumes and playing states, starts/stops audio
- `nextPreset() / prevPreset()` - Navigate presets with bounds checking
- `addPreset(name)` - Creates new preset from current sound states
- `removePreset(id)` - Cannot remove 'default' preset
- `renamePreset(id, newName)` - Updates preset name

**Sound Control:**
- `toggleSound(sound)` - Toggles playing state, initializes if needed, auto-sets volume to 0.5 if activating from 0
- `setSoundVolume(sound, volume)` - Updates volume, auto-starts if volume > 0 and not playing
- `resetVolumes()` - Stops all sounds, sets all volumes to 0
- `stopAll()` - Stops all initialized sounds

**Custom Sound Management:**
- `addCustomSound(sound)` - Adds to list, initializes, saves to SettingsService
- `removeCustomSound(sound)` - Stops, disposes, removes from list and settings

**Category Management:**
- `getSoundsByCategory(category)` - Filter sounds by category
- `categories` - Sorted list: [Nature, Travel, Interiors, Noise, Custom, ...others]

**UI State:**
- `hideInactive` / `setHideInactive(value)` - Per-preset setting to hide non-playing sounds
- `shouldShowSound(sound)` - Determines if sound should be visible based on preset settings

**Persistence:**
- `_saveCurrentState()` - Saves current volumes and playing states to active preset
- `saveState()` - Called from WidgetsBindingObserver when app goes background

**Volume Flow:**
1. User sets sound volume → `sound.volume = value` (0.0-1.0)
2. User sets global volume → `AudioService._globalVolume` (0.0-1.0)
3. Applied to player: `player.setVolume(soundVolume * globalVolume)`

#### SettingsService (`settings_service.dart`)
**Singleton wrapper for SharedPreferences.**

**Keys:**
- `global_volume: double` - Master volume level
- `playing: bool` - Whether any sound is playing
- `active_preset: String` - ID of active preset
- `presets: List<String>` - JSON encoded preset list
- `custom_sounds: List<String>` - JSON encoded custom sounds
- `background_playback: bool` - Continue playing when minimized
- `dark_mode: bool` - Dark theme enabled (default: true)
- `start_paused: bool` - Start with audio paused
- `hide_inactive_$presetId: bool` - Per-preset hide inactive setting
- `preset_volumes_$presetId: String` - JSON map of sound volumes
- `preset_muted_$presetId: String` - JSON map of mute states

**Methods:**
- `init()` - Initializes SharedPreferences instance
- `getPresets() / savePresets()` - Preset list persistence
- `getCustomSounds() / saveCustomSounds()` - Custom sound persistence
- `saveSoundState(presetId, sounds)` - Saves volumes and playing states
- `getPresetVolumes(presetId) / getPresetMuted(presetId)` - Retrieve saved states
- `clear()` - Clears all preferences (for testing/debugging)

### Screens (`lib/screens/`)

#### SoundMixerScreen (`sound_mixer_screen.dart`)
**Main UI with WidgetsBindingObserver for lifecycle management.**

**State:**
- `_audioService: AudioService` - Service reference
- `_isLoading: bool` - Initialization loading state
- `_error: String?` - Error message if initialization fails

**Lifecycle:**
- `initState()` - Adds observer, initializes AudioService
- `didChangeAppLifecycleState()` - Saves state when paused/inactive/detached
- `dispose()` - Removes observer, disposes AudioService

**UI Structure:**
```
Scaffold
├── AppBar
│   ├── Title: "AuraNoise"
│   ├── PresetSelector (dropdown + prev/next buttons)
│   ├── Global Volume Button (dialog)
│   └── Options Menu Button
├── Body
│   ├── AnimatedSize (VolumeControlPanel - shows only when sounds playing)
│   └── SingleChildScrollView
│       ├── Add Custom Sound button (if !hideInactive)
│       └── _buildCategorySection() for each category
└── (No FAB - each sound card is self-contained)
```

**Category Section (`_buildCategorySection()`):**
- Uses LayoutBuilder for responsive grid
- Calculates crossAxisCount: `(maxWidth / 140).floor().clamp(2, 6)`
- Grid with aspect ratio 0.9, spacing 8px
- Skips category entirely if hideInactive and no sounds playing

**Dialogs:**
- `_showGlobalVolumeDialog()` - Slider with percentage display
- `_showOptionsMenu()` - Bottom sheet with: Add Sound, Save Preset, Hide Inactive toggle, Reset Volumes, Settings
- `_showResetConfirm()` - Confirmation before resetting all volumes
- `_showSettingsDialog()` - Theme toggle, placeholders for Start Paused and Background Playback

### Widgets (`lib/widgets/`)

#### SoundItem (`sound_item.dart`)
**Compact grid card for a single sound.**

**Design:**
- Card with elevation 4 when playing, 1 when inactive
- Background: `primaryContainer` when playing, `surfaceContainerHighest` when inactive
- Padding: 12 (compact)
- Border radius: 12

**Content:**
- SVG icon: 56x56px (from `assets/icons/{sound.name}.svg`)
- Icon color: `onPrimaryContainer` when playing, `onSurfaceVariant` when inactive
- Title: 14px, bold when playing
- Volume slider: appears only when playing, height 24px with compact thumb

**Interaction:**
- Tap card: toggles sound on/off via `audioService.toggleSound(sound)`
- Slider: sets volume via `audioService.setSoundVolume(sound, value)`

**Fallback:**
- Custom sounds show `Icons.music_note` (56px) instead of SVG

#### VolumeControlPanel (`volume_control_panel.dart`)
**Collapsible panel showing active sounds with volume controls.**

**Features:**
- Shows only sounds where `sound.playing == true`
- Each row: icon + name + slider (0.0-1.0) + mute button + remove button
- Remove stops sound (sets playing=false, volume=0)
- Mute toggles playing state without changing volume
- Animated container height for smooth expand/collapse

#### PresetDialog (`preset_dialog.dart`)
**Dialog for creating new presets.**

- Text field for preset name
- "Save" button creates preset from current state
- Validation: non-empty name

#### PresetSelector (`preset_selector.dart`)
**AppBar dropdown for preset selection with navigation buttons.**

**Features:**
- Dropdown showing all presets with current preset selected
- Previous/Next arrows (disabled when at bounds)
- Long-press preset to rename
- Swipe or button navigation between presets

#### AddSoundDialog (`add_sound_dialog.dart`)
**Dialog for adding custom audio files.**

**Features:**
- File picker using `file_picker` package
- Supported formats: OGG, MP3, WAV, AAC, FLAC, M4A, OPUS
- Copies file to app documents directory (`sounds/`)
- Creates `Sound.custom()` instance
- Adds to AudioService and saves to SettingsService

## State Management

**Pattern:** Service-oriented with ChangeNotifier

**Flow:**
1. `AudioService` extends `ChangeNotifier`, holds all state
2. `SoundMixerScreen` calls `_audioService.addListener(_onAudioServiceChanged)`
3. State changes (volume, playing, preset) trigger `notifyListeners()` in service
4. Screen's `_onAudioServiceChanged()` calls `setState(() {})` to rebuild UI
5. Widgets receive updated data via constructor or service reference

**Benefits:**
- Simple, no external state management packages
- Reactive UI updates
- Centralized business logic

## Audio Implementation

### Lazy Initialization

**Problem:** Creating 14+ AudioPlayer instances at startup causes UI freeze

**Solution:**
- Sound._player is null until first play
- `Sound.init()` creates AudioPlayer only when needed
- UI renders immediately with placeholder state
- Background preloading initializes remaining sounds after first interaction

### Platform-Specific Backends

**Android:**
- Uses just_audio default AndroidAudioPlayer
- Exoplayer-based
- Background playback works with audio focus

**Linux/Windows (Desktop):**
- Uses just_audio_media_kit bridge
- MediaKit uses MPV for audio playback
- Requires initialization in main.dart:
  ```dart
  MediaKit.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
  ```
- MPV may log lavf cache warnings (non-fatal)

**Web:**
- Uses just_audio web implementation
- Custom sounds limited by browser storage

### Volume Control Architecture

**Three Levels:**
1. **Sound Volume** (0.0-1.0) - Individual sound level, saved per preset
2. **Global Volume** (0.0-1.0) - Master multiplier, applies to all sounds
3. **Actual Volume** - `soundVolume * globalVolume`, applied to AudioPlayer

**Muting:**
- `playing: false` stops audio but preserves volume value
- `muted` map in preset remembers playing state

### Looping

All sounds use `LoopMode.one` for infinite seamless looping:
```dart
await player.setLoopMode(LoopMode.one);
```

### Audio Assets

**Built-in:**
- Format: OGG (Vorbis codec)
- Location: `assets/sounds/*.ogg`
- Declared in `pubspec.yaml` flutter.assets section

**Custom:**
- Format: Any supported by platform (OGG, MP3, WAV, AAC, FLAC, M4A, OPUS)
- Location: App documents directory (`getApplicationDocumentsDirectory()/sounds/`)
- Copied on import, persisted across sessions

## Assets

### Audio Files (`assets/sounds/`)

| File | Category | Description |
|------|----------|-------------|
| rain.ogg | Nature | Rainfall sounds |
| storm.ogg | Nature | Thunderstorm |
| wind.ogg | Nature | Wind blowing |
| waves.ogg | Nature | Ocean waves |
| stream.ogg | Nature | Flowing water |
| birds.ogg | Nature | Bird songs |
| summer-night.ogg | Nature | Night ambience |
| train.ogg | Travel | Train sounds |
| boat.ogg | Travel | Boat/watercraft |
| city.ogg | Travel | Urban ambience |
| coffee-shop.ogg | Interiors | Cafe atmosphere |
| fireplace.ogg | Interiors | Crackling fire |
| pink-noise.ogg | Noise | Pink noise |
| white-noise.ogg | Noise | White noise |

### Icon Files (`assets/icons/`)

Each sound has a corresponding SVG icon:
- `rain.svg`, `storm.svg`, `wind.svg`, `waves.svg`, `stream.svg`, `birds.svg`
- `summer-night.svg`, `train.svg`, `boat.svg`, `city.svg`
- `coffee-shop.svg`, `fireplace.svg`, `pink-noise.svg`, `white-noise.svg`
- `sound-wave.svg` (generic), `add.svg` (for add button)

**Usage in SoundItem:**
```dart
SvgPicture.asset(
  'assets/icons/${sound.name}.svg',
  width: 56,
  height: 56,
  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
)
```

## Features

### Sound Categories
Sounds organized in responsive grid by category. Categories sorted: Nature, Travel, Interiors, Noise, Custom.

### Individual Volume Control
- Each sound has independent volume slider (0.0-1.0)
- Slider appears on card only when sound is playing
- Compact 24px slider with small thumb

### Global Volume
- Master control (0-100%) affecting all sounds multiplicatively
- Accessible via AppBar volume button
- Dialog shows current percentage

### Presets
- Save current sound mix (volumes + playing states)
- Each preset has independent settings:
  - Sound volumes per sound name
  - Mute/playing state per sound
  - `hideInactive` boolean
- Default preset cannot be deleted
- Navigation: dropdown or prev/next buttons
- Long-press to rename

### Custom Sounds
- Add audio files via file picker
- Supported: OGG, MP3, WAV, AAC, FLAC, M4A, OPUS
- Files copied to app documents directory
- Persist across sessions
- Appear in "Custom" category
- Can be removed (stops playback, deletes file reference)

### Hide Inactive
- Per-preset setting to show only playing sounds
- Toggle in options menu
- Reduces visual clutter when using presets

### Theme
- Material 3 design with dynamic color scheme
- Seed color: BlueGrey
- Default: Dark mode
- Switch in settings dialog
- ThemeData configured with card and slider themes

### Compact UI Design
- Grid cards: 140px min width, aspect ratio 0.9
- Card padding: 12px (reduced from 16px)
- Icon size: 56px (enlarged from 48px)
- Grid spacing: 8px (reduced from 12px)
- More sounds visible simultaneously

### Settings Persistence
All settings saved via SharedPreferences:
- Global volume
- Active preset ID
- All preset definitions
- Custom sound list
- Per-preset volumes and mute states
- Per-preset hideInactive setting
- Dark mode preference

**Persistence Triggers:**
- Preset switch
- Volume change
- Sound toggle
- App goes to background (via WidgetsBindingObserver)

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `just_audio` | ^0.10.5 | Core audio playback |
| `just_audio_media_kit` | ^2.1.0 | Desktop audio backend (Linux/Windows) |
| `media_kit_libs_linux` | any | Linux audio libraries |
| `media_kit_libs_windows_audio` | any | Windows audio libraries |
| `shared_preferences` | ^2.2.2 | Settings persistence |
| `file_picker` | ^8.0.0+1 | Custom sound file selection |
| `path_provider` | ^2.1.2 | App documents directory access |
| `uuid` | ^4.4.0 | Unique preset IDs |
| `flutter_svg` | ^2.0.10 | SVG icon rendering |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `flutter_lints` | ^6.0.0 | Lint rules (dev) |

## Platform Support

| Platform | Status | Backend | Notes |
|----------|--------|---------|-------|
| Android | ✅ Supported | just_audio (ExoPlayer) | Background playback supported |
| Linux | ✅ Supported | just_audio_media_kit (MPV) | Requires media_kit libs |
| Windows | ✅ Supported | just_audio_media_kit (MPV) | Requires media_kit libs |
| Web | ✅ Supported | just_audio_web | Custom sounds may be limited |
| iOS | ⚠️ Not tested | just_audio (AVPlayer) | Should work, needs testing |
| macOS | ⚠️ Not tested | just_audio (AVPlayer) | Should work, needs testing |

**Media Kit Notes:**
- Linux/Windows require `MediaKit.ensureInitialized()` before `runApp()`
- MPV logs lavf cache warnings for local files (non-fatal, can ignore)
- Audio players are lazy-loaded to prevent startup freeze

## Development Notes

### SDK Constraints
- Dart SDK: `^3.10.4` (pubspec.yaml environment)
- Flutter: Compatible with latest stable

### Analysis
- Uses `package:flutter_lints/flutter.yaml`
- Run `flutter analyze` to check
- Run `flutter dart fix` for auto-fixes

### Theme Configuration
- Material 3 enabled (`useMaterial3: true`)
- Card theme: RoundedRectangleBorder with 12px radius, elevation 2
- Slider theme: BlueGrey active track and thumb
- Color scheme generated from BlueGrey seed

### Logging
AudioService uses emoji-prefixed debug prints:
- 🎵 - Audio operations
- ✓ - Success
- ✗ - Errors
- Enable with `--verbose` or check debug console

### Performance Considerations
- **Lazy initialization**: AudioPlayers created only when first played
- **Background preloading**: Remaining sounds initialized after UI renders
- **Efficient rebuilds**: ChangeNotifier pattern minimizes unnecessary rebuilds
- **Responsive grid**: LayoutBuilder calculates optimal columns based on width

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with name filter
flutter test --name "SoundItem"
```

### Common Issues

**Issue:** Audio not playing on Linux/Windows
- **Solution:** Ensure MediaKit is initialized in main.dart

**Issue:** Custom sounds not persisting
- **Solution:** Check file picker returns valid path, verify permissions

**Issue:** UI freezes on startup
- **Solution:** This shouldn't happen with lazy initialization; check if preloading is blocking

**Issue:** Lavf cache warnings on Linux
- **Solution:** Non-fatal MPV warnings, can be ignored

## Adding New Built-in Sounds

1. Add `.ogg` audio file to `assets/sounds/`
2. Create `.svg` icon file in `assets/icons/` (same name as sound)
3. Add entry to `SoundGroups.groups` in `lib/models/sound_groups.dart`:
   ```dart
   {'name': 'new-sound', 'title': 'New Sound'},
   ```
4. Add audio asset to `pubspec.yaml`:
   ```yaml
   assets:
     - assets/sounds/new-sound.ogg
     - assets/icons/new-sound.svg
   ```
5. Run `flutter pub get` to update asset manifest
6. Test on all target platforms

## Key Implementation Details

1. **Lazy Audio Initialization**: AudioPlayers created only on first play to prevent startup freeze
2. **Background Preload**: After first interaction, remaining sounds preloaded without blocking UI
3. **State Persistence**: Sound volumes and playing states saved per preset, restored on preset switch
4. **App Lifecycle**: WidgetsBindingObserver saves state when app goes to background/inactive
5. **Volume Multiplication**: Final volume = soundVolume * globalVolume
6. **Category Ordering**: Hardcoded: Nature, Travel, Interiors, Noise, Custom
7. **Default Preset Protection**: Cannot delete preset with id='default'
8. **Custom Sound Storage**: Files copied to app documents, not assets
9. **SVG Icons**: All built-in sounds have matching SVG icons in assets/icons/
10. **Compact UI**: Cards are 140px min width with 56px icons and 12px padding for density

## References

- [Blanket](https://github.com/rafaelmardojai/blanket) - Inspiration
- [just_audio](https://pub.dev/packages/just_audio) - Audio playback
- [media_kit](https://github.com/media-kit/media-kit) - Desktop audio
- [flutter_svg](https://pub.dev/packages/flutter_svg) - SVG support
