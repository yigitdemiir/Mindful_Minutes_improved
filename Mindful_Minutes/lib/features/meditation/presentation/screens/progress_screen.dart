import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/progress_provider.dart';
import '../../providers/firestore_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

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
                    AppLocalizations.of(context)!.progress,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                // Stats Overview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        // Streak Card
                        streakAsync.when(
                          data: (streakData) => _buildStreakCard(
                            context,
                            streakData['current'] ?? 0,
                            streakData['best'] ?? 0,
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Center(
                            child: Text(
                              AppLocalizations.of(context)!.errorLoadingStreak,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: AppConstants.spacingM),
                        
                        // Stats Row
                        achievementsAsync.when(
                          data: (achievements) => Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatCard(
                                  context,
                                  AppLocalizations.of(context)!.totalMinutes,
                                  '${achievements['totalMinutes'] ?? 0}',
                                  Icons.timer_outlined,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingM),
                              Expanded(
                                child: _buildMiniStatCard(
                                  context,
                                  AppLocalizations.of(context)!.totalSessions,
                                  '${achievements['totalSessions'] ?? 0}',
                                  Icons.self_improvement_outlined,
                                  Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Center(
                            child: Text(
                              AppLocalizations.of(context)!.errorLoadingStats,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ),

                // Weekly Overview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.weeklyOverview,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(height: AppConstants.spacingM),
                        weeklyProgressAsync.when(
                          data: (weekProgress) => _buildWeeklyOverview(context, weekProgress),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Center(
                            child: Text(
                              AppLocalizations.of(context)!.errorLoadingWeeklyProgress,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: AppConstants.spacingL),
                      ],
                    ),
                  ),
                ),

                // Achievements section
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  sliver: achievementsAsync.when(
                    data: (achievements) => SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppConstants.spacingM,
                        crossAxisSpacing: AppConstants.spacingM,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.firstSteps,
                          AppLocalizations.of(context)!.completeMeditations,
                          Icons.play_circle_outlined,
                          Colors.green,
                          true,
                          _getProgressText(context, 'First Steps', achievements['totalSessions'] ?? 0),
                        ),
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.timeMaster,
                          AppLocalizations.of(context)!.totalMeditationTime,
                          Icons.timer_outlined,
                          Colors.blue,
                          true,
                          _getProgressText(context, 'Time Master', achievements['totalMinutes'] ?? 0),
                        ),
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.earlyBird,
                          AppLocalizations.of(context)!.morningMeditations,
                          Icons.wb_twilight_outlined,
                          Colors.amber,
                          true,
                          _getProgressText(context, 'Early Bird', achievements['earlyBirdSessions'] ?? 0),
                        ),
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.nightOwl,
                          AppLocalizations.of(context)!.nightMeditations,
                          Icons.bedtime_outlined,
                          Colors.indigo,
                          true,
                          _getProgressText(context, 'Night Owl', achievements['nightOwlSessions'] ?? 0),
                        ),
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.perfectCombo,
                          AppLocalizations.of(context)!.morningAndNight,
                          Icons.auto_awesome_outlined,
                          Colors.pink,
                          true,
                          _getProgressText(context, 'Perfect Combo', achievements['perfectComboDays'] ?? 0),
                        ),
                        _buildAchievementCard(
                          context,
                          AppLocalizations.of(context)!.deepFocusAchievement,
                          AppLocalizations.of(context)!.longMeditations,
                          Icons.psychology_outlined,
                          Colors.deepPurple,
                          true,
                          _getProgressText(context, 'Deep Focus', achievements['deepFocusSessions'] ?? 0),
                        ),
                      ]),
                    ),
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.errorLoadingAchievements,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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

  Widget _buildStreakCard(BuildContext context, int current, int best) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.deepOrange.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              Icons.local_fire_department_outlined,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.currentStreak,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${current} ${AppLocalizations.of(context)!.days}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.best(best),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayProgress(BuildContext context, String day, int minutes, bool isDone) {
    final double height = minutes > 0 ? 60 * (minutes / 30) : 20;
    
    return Column(
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.purple.withOpacity(isDone ? 0.4 : 0.1),
                Colors.purple.withOpacity(isDone ? 0.2 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          day,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(isDone ? 0.7 : 0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (minutes > 0)
          Text(
            '$minutes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  String _getProgressText(BuildContext context, String achievement, int current) {
    final sessions = AppLocalizations.of(context)!.achievementSessions;
    final minutes = AppLocalizations.of(context)!.achievementMinutes;
    final days = AppLocalizations.of(context)!.achievementDays;

    switch (achievement) {
      case 'First Steps':
        if (current >= 50) return '50/50 $sessions';
        if (current >= 25) return '$current/50 $sessions';
        if (current >= 10) return '$current/25 $sessions';
        if (current >= 5) return '$current/10 $sessions';
        if (current >= 1) return '$current/5 $sessions';
        return '0/1 $sessions';
      
      case 'Time Master':
        if (current >= 100) return '100/100 $minutes';
        if (current >= 60) return '$current/100 $minutes';
        if (current >= 30) return '$current/60 $minutes';
        if (current >= 15) return '$current/30 $minutes';
        if (current >= 5) return '$current/15 $minutes';
        return '0/5 $minutes';

      case 'Early Bird':
        if (current >= 20) return '20/20 $sessions';
        if (current >= 15) return '$current/20 $sessions';
        if (current >= 10) return '$current/15 $sessions';
        if (current >= 5) return '$current/10 $sessions';
        if (current >= 1) return '$current/5 $sessions';
        return '0/1 $sessions';

      case 'Night Owl':
        if (current >= 20) return '20/20 $sessions';
        if (current >= 15) return '$current/20 $sessions';
        if (current >= 10) return '$current/15 $sessions';
        if (current >= 5) return '$current/10 $sessions';
        if (current >= 1) return '$current/5 $sessions';
        return '0/1 $sessions';

      case 'Perfect Combo':
        if (current >= 10) return '10/10 $days';
        if (current >= 7) return '$current/10 $days';
        if (current >= 5) return '$current/7 $days';
        if (current >= 3) return '$current/5 $days';
        if (current >= 1) return '$current/3 $days';
        return '0/1 $days';

      case 'Deep Focus':
        if (current >= 15) return '15/15 $sessions';
        if (current >= 10) return '$current/15 $sessions';
        if (current >= 7) return '$current/10 $sessions';
        if (current >= 3) return '$current/7 $sessions';
        if (current >= 1) return '$current/3 $sessions';
        return '0/1 $sessions';
      
      default:
        return '0/1';
    }
  }

  Color _getProgressColor(String progress) {
    // Parse the progress fraction
    final parts = progress.split('/');
    final current = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
    final target = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    
    // Get the achievement type from the progress text
    final achievementType = parts[1].split(' ').last; // e.g., "sessions", "days", "min", etc.
    
    // Define stage thresholds based on achievement type
    Map<String, List<int>> stageThresholds = {
      'First Steps': [1, 5, 10, 25, 50],
      'Time Master': [5, 15, 30, 60, 100],
      'Early Bird': [1, 5, 10, 15, 20],
      'Night Owl': [1, 5, 10, 15, 20],
      'Perfect Combo': [1, 3, 5, 7, 10],
      'Deep Focus': [1, 3, 7, 10, 15],
    };
    
    final thresholds = stageThresholds[achievementType] ?? [1, 5, 10, 25, 50];
    
    // Return color based on current progress
    if (current == 0) {
      return Colors.grey; // Not started - Grey
    } else if (current >= thresholds[4]) {
      return const Color(0xFFE0115F); // Completed - Ruby
    } else if (current >= thresholds[3]) {
      return Colors.amber; // Stage 4 - Gold
    } else if (current >= thresholds[2]) {
      return Colors.purple; // Stage 3 - Purple
    } else if (current >= thresholds[1]) {
      return const Color(0xFF00BCD4); // Stage 2 - Cyan
    } else if (current >= thresholds[0]) {
      return const Color(0xFF4CAF50); // Stage 1 - Green
    } else {
      return Colors.grey; // Not started - Grey
    }
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isUnlocked,
    String progress,
  ) {
    final progressColor = _getProgressColor(progress);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            progressColor.withOpacity(isUnlocked ? 0.2 : 0.1),
            progressColor.withOpacity(isUnlocked ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: progressColor.withOpacity(isUnlocked ? 0.2 : 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isUnlocked ? progressColor : Colors.white.withOpacity(0.3),
            size: 28,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUnlocked ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(isUnlocked ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Text(
              progress,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isUnlocked ? progressColor : Colors.white.withOpacity(0.3),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildWeeklyOverview(BuildContext context, Map<String, int> weekProgress) {
    int totalMinutes = 0;
    weekProgress.forEach((_, minutes) => totalMinutes += minutes);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.deepPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
              final dayKey = '${day.year}-${day.month}-${day.day}';
              final minutes = weekProgress[dayKey] ?? 0;
              
              return _buildDayProgress(
                context,
                _getDayLabel(index),
                minutes,
                minutes > 0,
              );
            }),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      AppLocalizations.of(context)!.minutesThisWeek(totalMinutes),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int index) {
    switch (index) {
      case 0: return 'M';
      case 1: return 'T';
      case 2: return 'W';
      case 3: return 'T';
      case 4: return 'F';
      case 5: return 'S';
      case 6: return 'S';
      default: return '';
    }
  }
} 