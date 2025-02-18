import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/meditation.dart';
import '../../providers/meditation_library_provider.dart';
import 'meditation_session_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecommendedScreen extends ConsumerWidget {
  const RecommendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditations = ref.watch(meditationLibraryProvider)
        .where((m) => !m.isPremium)
        .toList();

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
                    AppLocalizations.of(context)!.recommended,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // Description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Text(
                      AppLocalizations.of(context)!.discoverMeditations,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                ),

                // Meditations List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                        child: _buildMeditationCard(context, meditations[index]),
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
    // Get category-based colors
    List<Color> gradientColors;
    switch (meditation.category) {
      case MeditationCategory.morning:
        gradientColors = [Colors.orange, Colors.orange];
      case MeditationCategory.focus:
        gradientColors = [Colors.blue, Colors.lightBlue];
      case MeditationCategory.anxiety:
        gradientColors = [Colors.teal, Colors.cyan];
      case MeditationCategory.evening:
        gradientColors = [Colors.indigo, Colors.blue];
      default:
        gradientColors = [Colors.purple, Colors.deepPurple];
    }

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
      default:
        title = meditation.title;
        description = meditation.description;
        duration = meditation.durationText;
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors.map((c) => c.withOpacity(0.2)).toList(),
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.2),
          width: 1,
        ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    meditation.icon,
                    color: gradientColors[0],
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        duration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
} 