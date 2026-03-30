// AuraNoise - A Flutter ambient noise app inspired by Blanket
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'screens/sound_mixer_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize media_kit only for desktop platforms (Linux/Windows)
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows)) {
    MediaKit.ensureInitialized();
    JustAudioMediaKit.ensureInitialized();
  }

  // Initialize settings service
  await SettingsService().init();

  runApp(const AuraNoiseApp());
}

class AuraNoiseApp extends StatelessWidget {
  const AuraNoiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return MaterialApp(
      title: 'AuraNoise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: settings.darkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.blueGrey,
          thumbColor: Colors.blueGrey,
          overlayColor: Colors.blueGrey.withAlpha(0x29),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SoundMixerScreen(),
    );
  }
}
