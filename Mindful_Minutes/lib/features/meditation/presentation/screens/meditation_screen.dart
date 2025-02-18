import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/meditation.dart';
import '../../providers/meditation_library_provider.dart';
import '../../providers/firestore_provider.dart';
import 'meditation_session_screen.dart';
import 'category_screen.dart';
import 'recommended_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeditationScreen extends ConsumerWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMeditationsAsync = ref.watch(recentMeditationsStreamProvider);
    final recommendedMeditations = ref.watch(recommendedMeditationsProvider);

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
                    AppLocalizations.of(context)!.meditate,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // Recent Sessions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.recentSessions,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(height: AppConstants.spacingM),
                        SizedBox(
                          height: 130,
                          child: recentMeditationsAsync.when(
                            data: (recentMeditations) {
                              if (recentMeditations.isEmpty) {
                                return Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.noRecentSessions,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentMeditations.length,
                                itemBuilder: (context, index) {
                                  final meditation = recentMeditations[index];
                                  return _buildRecentSessionCard(
                                    context,
                                    meditation,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stackTrace) => Center(
                              child: Text(
                                AppLocalizations.of(context)!.errorLoadingSessions,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommended
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recommended,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const RecommendedScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.seeAll,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),
                        const SizedBox(height: AppConstants.spacingM),
                        ...recommendedMeditations.map((meditation) => Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                          child: _buildRecommendedCard(context, meditation),
                        )),
                      ],
                    ),
                  ),
                ),

                // Browse Categories
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppConstants.spacingM,
                      crossAxisSpacing: AppConstants.spacingM,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildListDelegate(
                      [
                        _buildCategoryCard(
                          context,
                          AppLocalizations.of(context)!.morning,
                          Icons.wb_sunny_outlined,
                          Colors.orange,
                          MeditationCategory.morning,
                        ),
                        _buildCategoryCard(
                          context,
                          AppLocalizations.of(context)!.focus,
                          Icons.lens_outlined,
                          Colors.blue,
                          MeditationCategory.focus,
                        ),
                        _buildCategoryCard(
                          context,
                          AppLocalizations.of(context)!.anxiety,
                          Icons.healing_outlined,
                          Colors.teal,
                          MeditationCategory.anxiety,
                        ),
                        _buildCategoryCard(
                          context,
                          AppLocalizations.of(context)!.evening,
                          Icons.nightlight_outlined,
                          Colors.indigo,
                          MeditationCategory.evening,
                        ),
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

  void _startMeditation(BuildContext context, Meditation meditation) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => MeditationSessionScreen(
          title: meditation.title,
          duration: meditation.durationText,
          backgroundMusic: meditation.audioFile,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildRecentSessionCard(
    BuildContext context,
    Meditation meditation,
  ) {
    // Get localized title and duration
    String title;
    String duration;
    
    switch (meditation.title) {
      case "5-Second Test":
        title = AppLocalizations.of(context)!.fiveSecondTest;
        duration = AppLocalizations.of(context)!.oneMin;
      case "Morning Calm":
        title = AppLocalizations.of(context)!.morningCalm;
        duration = AppLocalizations.of(context)!.tenMin;
      case "Focus Flow":
        title = AppLocalizations.of(context)!.focusFlow;
        duration = AppLocalizations.of(context)!.twentyMin;
      case "Forest Bath":
        title = AppLocalizations.of(context)!.forestBath;
        duration = AppLocalizations.of(context)!.fifteenMin;
      case "Rain Peace":
        title = AppLocalizations.of(context)!.rainPeace;
        duration = AppLocalizations.of(context)!.fifteenMin;
      default:
        title = meditation.title;
        duration = meditation.durationText;
    }

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: AppConstants.spacingM),
      decoration: BoxDecoration(
        color: meditation.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () => _startMeditation(context, meditation),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meditation.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    meditation.icon,
                    color: meditation.accentColor,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }

  Widget _buildRecommendedCard(
    BuildContext context,
    Meditation meditation,
  ) {
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
        color: meditation.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () => _startMeditation(context, meditation),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: meditation.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    meditation.icon,
                    color: meditation.accentColor,
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
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        duration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
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
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    MeditationCategory category,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  category: category,
                  title: title,
                  icon: icon,
                  accentColor: color,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
} 