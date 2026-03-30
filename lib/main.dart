// AuraNoise - A Flutter ambient noise app inspired by Blanket
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'controllers/audio_controller.dart';
import 'theme/app_theme.dart';
import 'screens/sound_mixer_screen.dart';
import 'screens/preset_library_screen.dart';
import 'screens/settings_screen.dart';
import 'services/audio_service.dart';
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

  // Apply system UI overlay style
  AuraTheme.applySystemUIOverlay();

  // Initialize GetX controller
  Get.put(AudioController());

  runApp(const AuraNoiseApp());
}

class AuraNoiseApp extends StatelessWidget {
  const AuraNoiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AuraNoise',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.darkTheme,
      darkTheme: AuraTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigationScreen(),
    );
  }
}

/// Main navigation with bottom nav bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  final _navController = Get.put(NavigationController());
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _audioService.onAppBackground();
        break;
      case AppLifecycleState.resumed:
        _audioService.onAppForeground();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        // Do nothing for these states
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() => IndexedStack(
          index: _navController.currentIndex.value,
          children: const [
            SoundMixerScreen(),
            PresetLibraryScreen(),
            SettingsScreen(),
          ],
        )),
        bottomNavigationBar: _buildBottomNav(_navController),
      ),
    );
  }

  Widget _buildBottomNav(NavigationController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.surfaceContainerLow.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AuraRadius.lg),
          topRight: Radius.circular(AuraRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(controller, 0, Icons.tune, 'Mixer'),
              _buildNavItem(controller, 1, Icons.library_music, 'Presets'),
              _buildNavItem(controller, 2, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationController controller, int index, IconData icon, String label) {
    return Obx(() {
      final isActive = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  gradient: AuraColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AuraRadius.full),
                  boxShadow: [AuraShadows.primaryGlow],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AuraColors.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AuraTypography.labelSmall.copyWith(
                  color: isActive ? Colors.white : AuraColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Navigation controller
class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
