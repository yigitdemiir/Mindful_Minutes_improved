import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/meditation_session_provider.dart';

class VolumeControlSheet extends ConsumerWidget {
  final MeditationSessionConfig sessionConfig;

  const VolumeControlSheet({
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
                    'Volume',
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
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: SliderTheme(
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
            ),
          ],
        ),
      ),
    );
  }
} 