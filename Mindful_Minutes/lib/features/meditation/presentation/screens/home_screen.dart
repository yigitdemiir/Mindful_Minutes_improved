import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../models/meditation.dart';
import '../../providers/meditation_library_provider.dart';
import 'meditation_screen.dart';
import 'meditation_session_screen.dart';
import 'category_screen.dart';
import '../../../../features/auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';

class DailyChallenge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const DailyChallenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class DiscoverCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final MeditationCategory category;

  const DiscoverCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.category,
  });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.goodMorning;
    } else if (hour < 17) {
      return AppLocalizations.of(context)!.goodAfternoon;
    } else {
      return AppLocalizations.of(context)!.goodEvening;
    }
  }

  String _getDailyQuote(BuildContext context) {
    final hour = DateTime.now().hour;
    
    // Morning quotes (5-11)
    if (hour >= 5 && hour < 12) {
      return AppLocalizations.of(context)!.morningQuote;
    }
    // Afternoon quotes (12-16)
    else if (hour >= 12 && hour < 17) {
      return AppLocalizations.of(context)!.afternoonQuote;
    }
    // Evening quotes (17-21)
    else if (hour >= 17 && hour < 22) {
      return AppLocalizations.of(context)!.eveningQuote;
    }
    // Night quotes (22-4)
    else {
      return AppLocalizations.of(context)!.nightQuote;
    }
  }

  String _getRecommendedSessionTitle(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.morningMeditation;
    } else if (hour < 17) {
      return AppLocalizations.of(context)!.afternoonBreak;
    } else if (hour < 22) {
      return AppLocalizations.of(context)!.eveningWindDown;
    } else {
      return AppLocalizations.of(context)!.sleepWell;
    }
  }

  String _getDailyTip(BuildContext context) {
    final dayOfYear = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final tipNumber = (dayOfYear % 15) + 1; // We have 15 tips
    
    // Get the localized tip using the dynamic key
    switch (tipNumber) {
      case 1: return AppLocalizations.of(context)!.dailyTip1;
      case 2: return AppLocalizations.of(context)!.dailyTip2;
      case 3: return AppLocalizations.of(context)!.dailyTip3;
      case 4: return AppLocalizations.of(context)!.dailyTip4;
      case 5: return AppLocalizations.of(context)!.dailyTip5;
      case 6: return AppLocalizations.of(context)!.dailyTip6;
      case 7: return AppLocalizations.of(context)!.dailyTip7;
      case 8: return AppLocalizations.of(context)!.dailyTip8;
      case 9: return AppLocalizations.of(context)!.dailyTip9;
      case 10: return AppLocalizations.of(context)!.dailyTip10;
      case 11: return AppLocalizations.of(context)!.dailyTip11;
      case 12: return AppLocalizations.of(context)!.dailyTip12;
      case 13: return AppLocalizations.of(context)!.dailyTip13;
      case 14: return AppLocalizations.of(context)!.dailyTip14;
      case 15: return AppLocalizations.of(context)!.dailyTip15;
      default: return AppLocalizations.of(context)!.dailyTip1;
    }
  }

  DailyChallenge _getDailyChallenge() {
    final challenges = [
      DailyChallenge(
        title: 'Mindful Morning',
        description: 'Start your day with a 5-minute breathing exercise',
        icon: Icons.wb_sunny_outlined,
        color: Colors.orange,
      ),
      DailyChallenge(
        title: 'Stress Relief',
        description: 'Take three 2-minute breaks during your busy hours',
        icon: Icons.spa_outlined,
        color: Colors.purple,
      ),
      DailyChallenge(
        title: 'Gratitude Practice',
        description: 'Reflect on three things you\'re grateful for today',
        icon: Icons.favorite_outline,
        color: Colors.pink,
      ),
      DailyChallenge(
        title: 'Digital Detox',
        description: 'Take a 10-minute break from all screens',
        icon: Icons.phonelink_erase_outlined,
        color: Colors.blue,
      ),
      DailyChallenge(
        title: 'Nature Connection',
        description: 'Spend 5 minutes observing nature mindfully',
        icon: Icons.nature_outlined,
        color: Colors.green,
      ),
      DailyChallenge(
        title: 'Mindful Walking',
        description: 'Take a short walk focusing on each step',
        icon: Icons.directions_walk_outlined,
        color: Colors.teal,
      ),
      DailyChallenge(
        title: 'Body Scan',
        description: 'Practice a quick body awareness meditation',
        icon: Icons.accessibility_new_outlined,
        color: Colors.indigo,
      ),
    ];

    final dayOfYear = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    return challenges[dayOfYear % challenges.length];
  }

  List<DiscoverCategory> _getRandomCategories(BuildContext context) {
    final allCategories = [
      DiscoverCategory(
        title: AppLocalizations.of(context)!.sleepAndRelax,
        description: AppLocalizations.of(context)!.sleepAndRelaxDesc,
        icon: Icons.nightlight_outlined,
        color: Colors.indigo,
        gradientColors: [Colors.indigo, Colors.blue],
        category: MeditationCategory.evening,
      ),
      DiscoverCategory(
        title: AppLocalizations.of(context)!.reduceAnxiety,
        description: AppLocalizations.of(context)!.reduceAnxietyDesc,
        icon: Icons.healing_outlined,
        color: Colors.teal,
        gradientColors: [Colors.teal, Colors.cyan],
        category: MeditationCategory.anxiety,
      ),
      DiscoverCategory(
        title: AppLocalizations.of(context)!.focusAndConcentrate,
        description: AppLocalizations.of(context)!.focusAndConcentrateDesc,
        icon: Icons.circle_outlined,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlue],
        category: MeditationCategory.focus,
      ),
      DiscoverCategory(
        title: AppLocalizations.of(context)!.quickBreak,
        description: AppLocalizations.of(context)!.quickBreakDesc,
        icon: Icons.wb_sunny_outlined,
        color: Colors.orange,
        gradientColors: [Colors.orange, Colors.deepOrange],
        category: MeditationCategory.morning,
      ),
    ];

    // Shuffle the list and take first 2 items
    allCategories.shuffle();
    return allCategories.take(2).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyChallenge = _getDailyChallenge();
    final randomCategories = _getRandomCategories(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leadingWidth: 80,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final currentLocale = ref.watch(languageProvider);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLanguageButton(
                                  context,
                                  'EN',
                                  currentLocale.languageCode == 'en',
                                  () => ref.read(languageProvider.notifier).changeLanguage('en'),
                                ),
                                _buildLanguageButton(
                                  context,
                                  'TR',
                                  currentLocale.languageCode == 'tr',
                                  () => ref.read(languageProvider.notifier).changeLanguage('tr'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      _getGreeting(context),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person_outline, color: Colors.white),
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: '',
                            barrierColor: Colors.black38,
                            transitionDuration: const Duration(milliseconds: 200),
                            pageBuilder: (context, anim1, anim2) => Container(),
                            transitionBuilder: (context, anim1, anim2, child) {
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(anim1),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SafeArea(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        margin: const EdgeInsets.only(top: 8, right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.logout_outlined,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                              title: Text(
                                                AppLocalizations.of(context)!.logout,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                              ),
                                              onTap: () async {
                                                final BuildContext currentContext = context;
                                                await ref.read(authServiceProvider).signOut();
                                                Future.delayed(Duration.zero, () {
                                                  Navigator.pop(currentContext);
                                                  currentContext.go('/');
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  // Daily Quote
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingL),
                      child: Text(
                        _getDailyQuote(context),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2),
                    ),
                  ),

                  // Discover Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.discover,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  // Force rebuild to get new random categories
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                            ],
                          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                          const SizedBox(height: AppConstants.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDiscoverCard(
                                  context,
                                  randomCategories[0].title,
                                  randomCategories[0].description,
                                  randomCategories[0].icon,
                                  randomCategories[0].color,
                                  randomCategories[0].gradientColors,
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CategoryScreen(
                                          category: randomCategories[0].category,
                                          title: randomCategories[0].title,
                                          icon: randomCategories[0].icon,
                                          accentColor: randomCategories[0].color,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingM),
                              Expanded(
                                child: _buildDiscoverCard(
                                  context,
                                  randomCategories[1].title,
                                  randomCategories[1].description,
                                  randomCategories[1].icon,
                                  randomCategories[1].color,
                                  randomCategories[1].gradientColors,
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CategoryScreen(
                                          category: randomCategories[1].category,
                                          title: randomCategories[1].title,
                                          icon: randomCategories[1].icon,
                                          accentColor: randomCategories[1].color,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                        ],
                      ),
                    ),
                  ),

                  // Spacer
                  SliverToBoxAdapter(
                    child: const SizedBox(height: AppConstants.spacingL),
                  ),

                  // Today's Plan
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.todaysPlan,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                          const SizedBox(height: AppConstants.spacingM),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.teal.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.radiusL),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                onTap: () {
                                  final meditation = ref.read(meditationLibraryProvider.notifier).getQuickStartMeditation();
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
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(AppConstants.spacingM),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                        ),
                                        child: Icon(
                                          Icons.schedule_outlined,
                                          color: Colors.white,
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
                                              _getRecommendedSessionTitle(context),
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!.perfectForNow,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                        ],
                      ),
                    ),
                  ),

                  // Daily Wisdom
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.withOpacity(0.2),
                              Colors.orange.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppConstants.spacingS),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      ),
                                      child: Icon(
                                        Icons.tips_and_updates_outlined,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spacingM),
                                    Text(
                                      AppLocalizations.of(context)!.dailyWisdom,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.amber.withOpacity(0.7),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Text(
                              _getDailyTip(context),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                    ),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spacingM),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      height: 140,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
} 