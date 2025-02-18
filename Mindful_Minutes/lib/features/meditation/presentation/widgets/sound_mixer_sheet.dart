import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/meditation_session_provider.dart';

class SoundMixerSheet extends ConsumerWidget {
  final MeditationSessionConfig sessionConfig;

  const SoundMixerSheet({
    super.key,
    required this.sessionConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(meditationSessionProvider(sessionConfig));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sound Mixer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      sessionState.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(meditationSessionProvider(sessionConfig).notifier).toggleMute();
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: Text(
                'Background Music',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
              child: Row(
                children: [
                  _buildSoundButton(
                    context,
                    ref,
                    'Rain',
                    Icons.water_drop_outlined,
                    'assets/sounds/meditations/anxiety_release/sleep_rain.mp3',
                  ),
                  _buildSoundButton(
                    context,
                    ref,
                    'Ocean',
                    Icons.waves_outlined,
                    'assets/sounds/meditations/evening_peace/ocean.mp3',
                  ),
                  _buildSoundButton(
                    context,
                    ref,
                    'Forest',
                    Icons.forest_outlined,
                    'assets/sounds/meditations/anxiety_release/forest.mp3',
                  ),
                  _buildSoundButton(
                    context,
                    ref,
                    'Wind',
                    Icons.air_outlined,
                    'assets/sounds/meditations/stress_relief/wind.mp3',
                  ),
                  _buildSoundButton(
                    context,
                    ref,
                    'River',
                    Icons.water_outlined,
                    'assets/sounds/meditations/focus_flow/river.mp3',
                  ),
                  _buildSoundButton(
                    context,
                    ref,
                    'Bowls',
                    Icons.brightness_7_outlined,
                    'assets/sounds/meditations/morning_calm/crystal_bowls.mp3',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Volume',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: sessionState.musicVolume,
                      onChanged: (value) {
                        ref.read(meditationSessionProvider(sessionConfig).notifier)
                            .setMusicVolume(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    String soundFile,
  ) {
    final sessionState = ref.watch(meditationSessionProvider(sessionConfig));
    final isSelected = sessionState.backgroundMusic == soundFile;

    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              onTap: () {
                ref.read(meditationSessionProvider(sessionConfig).notifier)
                    .setBackgroundMusic(soundFile);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 