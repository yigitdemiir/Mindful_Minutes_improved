import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/meditation.dart';
import '../../providers/meditation_library_provider.dart';
import '../../providers/bedtime_provider.dart';
import '../screens/meditation_session_screen.dart';

class SleepSound {
  final String title;
  final String description;
  final IconData icon;
  final String audioFile;
  final Color accentColor;

  const SleepSound({
    required this.title,
    required this.description,
    required this.icon,
    required this.audioFile,
    required this.accentColor,
  });
}

final sleepSounds = [
  SleepSound(
    title: 'nature',
    description: 'natureDesc',
    icon: Icons.forest_outlined,
    audioFile: 'sleep_nature',
    accentColor: Colors.green,
  ),
  SleepSound(
    title: 'fireplace',
    description: 'fireplaceDesc',
    icon: Icons.local_fire_department_outlined,
    audioFile: 'sleep_crackling',
    accentColor: Colors.orange,
  ),
  SleepSound(
    title: 'rain',
    description: 'rainDesc',
    icon: Icons.water_drop_outlined,
    audioFile: 'sleep_rain',
    accentColor: Colors.blue,
  ),
  SleepSound(
    title: 'ocean',
    description: 'oceanDesc',
    icon: Icons.water_outlined,
    audioFile: 'sleep_waves',
    accentColor: Colors.teal,
  ),
];

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepMeditations = ref.watch(meditationsByCategoryProvider(MeditationCategory.evening));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    AppLocalizations.of(context)!.sleep,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // Sleep Sounds
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sleepSounds,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(height: AppConstants.spacingM),
                        ...sleepSounds.map((sound) => Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                          child: _buildSoundCard(
                            context,
                            sound,
                          ),
                        )),
                        const SizedBox(height: AppConstants.spacingL),
                        _buildBedtimeReminderCard(context, ref),
                        const SizedBox(height: AppConstants.spacingL),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard(
    BuildContext context,
    SleepSound sound,
  ) {
    // Get localized title and description based on sound type
    String title;
    String description;
    
    switch (sound.title) {
      case 'nature':
        title = AppLocalizations.of(context)!.nature;
        description = AppLocalizations.of(context)!.natureDesc;
      case 'fireplace':
        title = AppLocalizations.of(context)!.fireplace;
        description = AppLocalizations.of(context)!.fireplaceDesc;
      case 'rain':
        title = AppLocalizations.of(context)!.rain;
        description = AppLocalizations.of(context)!.rainDesc;
      case 'ocean':
        title = AppLocalizations.of(context)!.ocean;
        description = AppLocalizations.of(context)!.oceanDesc;
      default:
        title = sound.title;
        description = sound.description;
    }

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: sound.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () {
            _showDurationPicker(context, sound);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sound.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    sound.icon,
                    color: sound.accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  void _showDurationPicker(BuildContext context, SleepSound sound) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectDuration,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDurationOption(context, sound, 15, AppLocalizations.of(context)!.fifteenMin),
                      _buildDurationOption(context, sound, 30, AppLocalizations.of(context)!.thirtyMin),
                      _buildDurationOption(context, sound, 45, AppLocalizations.of(context)!.fortyFiveMin),
                      _buildDurationOption(context, sound, -1, '∞'),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(BuildContext context, SleepSound sound, int minutes, String label) {
    // Get localized title based on sound type
    String title;
    switch (sound.title) {
      case 'nature':
        title = AppLocalizations.of(context)!.nature;
      case 'fireplace':
        title = AppLocalizations.of(context)!.fireplace;
      case 'rain':
        title = AppLocalizations.of(context)!.rain;
      case 'ocean':
        title = AppLocalizations.of(context)!.ocean;
      default:
        title = sound.title;
    }

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => MeditationSessionScreen(
              title: title,
              duration: label,
              backgroundMusic: sound.audioFile,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: sound.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: sound.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedtimeReminderCard(BuildContext context, WidgetRef ref) {
    final bedtime = ref.watch(bedtimeProvider);
    final formattedTime = bedtime != null 
        ? '${bedtime.hour > 12 ? bedtime.hour - 12 : bedtime.hour}:${bedtime.minute.toString().padLeft(2, '0')} ${bedtime.hour >= 12 ? 'PM' : 'AM'}'
        : '--:--';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.bedtimeReminder,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.bedtimeReminderDesc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedTime,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: bedtime ?? const TimeOfDay(hour: 22, minute: 30),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: Theme.of(context).colorScheme.background,
                            hourMinuteTextColor: Colors.white,
                            dayPeriodTextColor: Colors.white,
                            dialHandColor: Colors.indigo,
                            dialBackgroundColor: Colors.indigo.withOpacity(0.2),
                            dialTextColor: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (newTime != null) {
                    ref.read(bedtimeProvider.notifier).setBedtime(newTime);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.changeTime,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
} 