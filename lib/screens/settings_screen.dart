// Settings & Timer Screen - GetX version with reactive state
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../controllers/audio_controller.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AuraSpacing.xl,
              AuraSpacing.xxl + 60,
              AuraSpacing.xl,
              AuraSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AuraColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AuraRadius.full),
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: AuraColors.primary,
                    ),
                  ),
                  const SizedBox(width: AuraSpacing.md),
                  Text(
                    'Settings',
                    style: AuraTypography.headlineSmall.copyWith(
                      color: AuraColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Sleep Timer Section
                _buildTimerSection(context),
                const SizedBox(height: AuraSpacing.xxl),
                // Preferences Section
                _buildPreferencesSection(),
                const SizedBox(height: AuraSpacing.xxl),
                // About Section
                _buildAboutSection(),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    final timerController = Get.put(TimerController());

    return Obx(() => GlassPanel(
      padding: const EdgeInsets.all(AuraSpacing.xl),
      child: Column(
        children: [
          Text(
            'Sleep Timer',
            style: AuraTypography.uppercaseLabel,
          ),
          const SizedBox(height: AuraSpacing.xxl),
          // Circular countdown - Aura style
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AuraColors.surfaceContainerHighest,
                      width: 8,
                    ),
                  ),
                ),
                // Progress ring - custom painted
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: TimerProgressPainter(
                      progress: timerController.progress,
                      color: AuraColors.primary,
                      strokeWidth: 8,
                    ),
                  ),
                ),
                // Glow effect when running
                if (timerController.isRunning.value)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AuraColors.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                // Center content
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuraColors.surfaceContainerLow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Time display
                      Text(
                        timerController.isRunning.value
                            ? '${timerController.remainingMinutes.value}'
                            : '${timerController.timerMinutes.value}',
                        style: AuraTypography.displayMedium.copyWith(
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timerController.isRunning.value ? 'min left' : 'minutes',
                        style: AuraTypography.bodySmall.copyWith(
                          color: AuraColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Status indicator
                      if (timerController.isRunning.value)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AuraColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AuraColors.primary.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.xxl),
          // Duration slider with Aura styling
          if (!timerController.isRunning.value)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5 min',
                        style: AuraTypography.labelSmall.copyWith(
                          color: AuraColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${timerController.timerMinutes.value} min',
                        style: AuraTypography.labelMedium.copyWith(
                          color: AuraColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '120 min',
                        style: AuraTypography.labelSmall.copyWith(
                          color: AuraColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AuraSpacing.sm),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AuraColors.primary,
                      inactiveTrackColor: AuraColors.surfaceContainerHighest,
                      thumbColor: AuraColors.primary,
                      overlayColor: AuraColors.primary.withValues(alpha: 0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 4,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                    ),
                    child: Slider(
                      value: timerController.timerMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      onChanged: (value) => timerController.setTimerMinutes(value.round()),
                    ),
                  ),
                  // Quick select buttons
                  const SizedBox(height: AuraSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AuraSpacing.sm,
                    runSpacing: AuraSpacing.sm,
                    children: [
                      _buildQuickTimeButton(timerController, 15, '15m'),
                      _buildQuickTimeButton(timerController, 30, '30m'),
                      _buildQuickTimeButton(timerController, 45, '45m'),
                      _buildQuickTimeButton(timerController, 60, '1h'),
                    ],
                  ),
                ],
              ),
            ),
          // Running indicator
          if (timerController.isRunning.value)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuraSpacing.lg,
                vertical: AuraSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AuraColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AuraRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: AuraColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AuraSpacing.sm),
                  Text(
                    'Timer active',
                    style: AuraTypography.bodyMedium.copyWith(
                      color: AuraColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AuraSpacing.xxl),
          // Start/Cancel button with Aura styling
          GestureDetector(
            onTap: timerController.toggleTimer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: timerController.isRunning.value
                    ? null
                    : AuraColors.primaryGradient,
                color: timerController.isRunning.value
                    ? AuraColors.surfaceContainerHighest
                    : null,
                borderRadius: BorderRadius.circular(AuraRadius.full),
                boxShadow: timerController.isRunning.value
                    ? null
                    : [
                        BoxShadow(
                          color: AuraColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Text(
                timerController.isRunning.value ? 'Cancel Timer' : 'Start Timer',
                style: AuraTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: timerController.isRunning.value
                      ? AuraColors.error
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildQuickTimeButton(TimerController controller, int minutes, String label) {
    final isSelected = controller.timerMinutes.value == minutes;
    return GestureDetector(
      onTap: () => controller.setTimerMinutes(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.md,
          vertical: AuraSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AuraColors.primary.withValues(alpha: 0.2)
              : AuraColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          border: Border.all(
            color: isSelected
                ? AuraColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AuraTypography.labelMedium.copyWith(
            color: isSelected ? AuraColors.primary : AuraColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final settingsController = Get.put(SettingsController());

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AuraSpacing.sm),
          child: Text(
            'Preferences',
            style: AuraTypography.titleMedium.copyWith(
              color: AuraColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AuraSpacing.lg),
        // Wake Lock
        _buildPreferenceTile(
          icon: Icons.lightbulb_outline,
          title: 'Keep Screen On',
          subtitle: 'Prevent device from sleeping while playing',
          isActive: settingsController.wakeLock.value,
          onToggle: settingsController.setWakeLock,
        ),
        const SizedBox(height: AuraSpacing.md),
        // Start Paused
        _buildPreferenceTile(
          icon: Icons.motion_photos_paused,
          title: 'Start Paused',
          subtitle: 'Prevent auto-play on launch',
          isActive: settingsController.startPaused.value,
          onToggle: settingsController.setStartPaused,
          isSecondary: true,
        ),
        const SizedBox(height: AuraSpacing.md),
        // Background Playback
        _buildPreferenceTile(
          icon: Icons.graphic_eq,
          title: 'Background Playback',
          subtitle: 'Continue playing when app is minimized',
          isActive: settingsController.backgroundPlayback.value,
          onToggle: settingsController.setBackgroundPlayback,
        ),
      ],
    ));
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required ValueChanged<bool> onToggle,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AuraColors.primary.withValues(alpha: 0.2)
                    : AuraColors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? AuraColors.primary : AuraColors.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuraTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AuraTypography.bodySmall.copyWith(
                      color: AuraColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle switch
            Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? AuraColors.primary.withValues(alpha: 0.2)
                    : AuraColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AuraRadius.full),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isActive ? AuraColors.primary : AuraColors.outline,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final appInfoController = Get.put(AppInfoController());

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AuraSpacing.sm),
          child: Text(
            'Support & AuraNoise',
            style: AuraTypography.titleMedium.copyWith(
              color: AuraColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AuraSpacing.lg),
        // Open Source
        GestureDetector(
          onTap: () {
            // Open GitHub link
          },
          child: Container(
            padding: const EdgeInsets.all(AuraSpacing.lg),
            decoration: BoxDecoration(
              color: AuraColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AuraRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AuraColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.code,
                    color: AuraColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AuraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Source',
                        style: AuraTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Contribute on GitHub',
                        style: AuraTypography.bodySmall.copyWith(
                          color: AuraColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new,
                  color: AuraColors.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AuraSpacing.md),
        // Version
        Container(
          padding: const EdgeInsets.all(AuraSpacing.lg),
          decoration: BoxDecoration(
            color: AuraColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AuraColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info,
                  color: AuraColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: AuraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version',
                      style: AuraTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      appInfoController.version,
                      style: AuraTypography.bodySmall.copyWith(
                        color: AuraColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AuraColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AuraRadius.full),
                ),
                child: Text(
                  'UPDATED',
                  style: AuraTypography.labelSmall.copyWith(
                    color: AuraColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Footer decoration
        const SizedBox(height: AuraSpacing.xxl),
        Center(
          child: Opacity(
            opacity: 0.2,
            child: Column(
              children: [
                Text(
                  'AURANOISE',
                  style: AuraTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.05,
                  ),
                ),
                const SizedBox(height: AuraSpacing.xs),
                Text(
                  'Design Sanctuary',
                  style: AuraTypography.labelSmall.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

/// Timer Controller for reactive timer state
class TimerController extends GetxController {
  final AudioController _audioController = AudioController.to;

  final timerMinutes = 45.obs;
  final remainingMinutes = 45.obs;
  final isRunning = false.obs;
  Timer? _timer;

  double get progress {
    if (timerMinutes.value == 0) return 0;
    return remainingMinutes.value / timerMinutes.value;
  }

  void setTimerMinutes(int value) {
    timerMinutes.value = value;
    remainingMinutes.value = value;
  }

  void toggleTimer() {
    if (isRunning.value) {
      _timer?.cancel();
      isRunning.value = false;
      remainingMinutes.value = timerMinutes.value;
    } else {
      isRunning.value = true;
      remainingMinutes.value = timerMinutes.value;

      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        remainingMinutes.value--;

        if (remainingMinutes.value <= 0) {
          _timer?.cancel();
          _audioController.stopAll();
          isRunning.value = false;
          remainingMinutes.value = timerMinutes.value;
        }
      });
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

/// Settings Controller for reactive settings state
class SettingsController extends GetxController {
  final SettingsService _settings = SettingsService();

  final wakeLock = false.obs;
  final startPaused = false.obs;
  final backgroundPlayback = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    wakeLock.value = _settings.getWakeLock();
    startPaused.value = _settings.getStartPaused();
    backgroundPlayback.value = _settings.getBackgroundPlayback();
  }

  void setWakeLock(bool value) {
    wakeLock.value = value;
    _settings.setWakeLock(value);
    // Apply immediately
    _applyWakeLock(value);
  }

  void _applyWakeLock(bool enabled) {
    if (enabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void setStartPaused(bool value) {
    startPaused.value = value;
    _settings.setStartPaused(value);
  }

  void setBackgroundPlayback(bool value) {
    backgroundPlayback.value = value;
    _settings.setBackgroundPlayback(value);
  }
}

/// App Info Controller for package version
class AppInfoController extends GetxController {
  final packageInfo = Rxn<PackageInfo>();

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    packageInfo.value = await PackageInfo.fromPlatform();
  }

  String get version {
    if (packageInfo.value == null) return '1.0.0';
    return '${packageInfo.value!.version}+${packageInfo.value!.buildNumber}';
  }
}

/// Custom painter for the timer progress ring
class TimerProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  TimerProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw progress arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-90 degrees) and go clockwise
    final sweepAngle = -2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
