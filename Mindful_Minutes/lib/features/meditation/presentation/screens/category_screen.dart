import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/meditation.dart';
import '../../providers/meditation_library_provider.dart';
import 'meditation_session_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryScreen extends ConsumerWidget {
  final MeditationCategory category;
  final String title;
  final IconData icon;
  final Color accentColor;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditations = ref.watch(meditationsByCategoryProvider(category));

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
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // Category Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Icon(
                            icon,
                            color: accentColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.meditations,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.sessions(meditations.length),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                ),

                // Meditations Grid
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppConstants.spacingM,
                      crossAxisSpacing: AppConstants.spacingM,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMeditationCard(
                        context,
                        meditations[index],
                      ),
                      childCount: meditations.length,
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

  Widget _buildMeditationCard(BuildContext context, Meditation meditation) {
    // Get localized title and description based on meditation type
    String title;
    String description;
    String duration;
    
    switch (meditation.title) {
      case "5-Second Test":
        title = AppLocalizations.of(context)!.fiveSecondTest;
        description = AppLocalizations.of(context)!.quickTestMeditation;
        duration = AppLocalizations.of(context)!.oneMin;
      case "Morning Calm":
        title = AppLocalizations.of(context)!.morningCalm;
        description = AppLocalizations.of(context)!.startDayWithCrystals;
        duration = AppLocalizations.of(context)!.tenMin;
      case "Focus Flow":
        title = AppLocalizations.of(context)!.focusFlow;
        description = AppLocalizations.of(context)!.enhanceConcentration;
        duration = AppLocalizations.of(context)!.twentyMin;
      case "Forest Bath":
        title = AppLocalizations.of(context)!.forestBath;
        description = AppLocalizations.of(context)!.findCalmInForest;
        duration = AppLocalizations.of(context)!.fifteenMin;
      case "Rain Peace":
        title = AppLocalizations.of(context)!.rainPeace;
        description = AppLocalizations.of(context)!.windDownWithRain;
        duration = AppLocalizations.of(context)!.fifteenMin;
      case "Ocean Calm":
        title = AppLocalizations.of(context)!.oceanCalm;
        description = AppLocalizations.of(context)!.releaseAnxietyWithOcean;
        duration = AppLocalizations.of(context)!.twentyMin;
      case "Odak Akışı":
        title = AppLocalizations.of(context)!.odakAkisi;
        description = AppLocalizations.of(context)!.riverConcentration;
        duration = AppLocalizations.of(context)!.twentyMin;
      case "Deep Focus":
        title = AppLocalizations.of(context)!.deepFocus;
        description = AppLocalizations.of(context)!.concentrateWithGreenNoise;
        duration = AppLocalizations.of(context)!.twentyFiveMin;
      case "Wind Release":
        title = AppLocalizations.of(context)!.windRelease;
        description = AppLocalizations.of(context)!.driftWithWindSounds;
        duration = AppLocalizations.of(context)!.twentyMin;
      default:
        title = meditation.title;
        description = meditation.description;
        duration = meditation.durationText;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => MeditationSessionScreen(
                  title: title,
                  duration: duration,
                  backgroundMusic: meditation.audioFile,
                ),
                fullscreenDialog: true,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meditation.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    meditation.icon,
                    color: meditation.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    if (meditation.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.pro,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
} 