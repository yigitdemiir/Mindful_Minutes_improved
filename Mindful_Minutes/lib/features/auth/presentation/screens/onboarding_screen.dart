import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardFeature {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;

  const OnboardFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      OnboardFeature(
        title: AppLocalizations.of(context)!.dailyMeditation,
        description: AppLocalizations.of(context)!.dailyMeditationDesc,
        icon: Icons.self_improvement,
        colors: [Colors.purple, Colors.blue],
      ),
      OnboardFeature(
        title: AppLocalizations.of(context)!.sleepBetter,
        description: AppLocalizations.of(context)!.sleepBetterDesc,
        icon: Icons.nightlight_outlined,
        colors: [Colors.indigo, Colors.blue],
      ),
      OnboardFeature(
        title: AppLocalizations.of(context)!.trackProgress,
        description: AppLocalizations.of(context)!.trackProgressDesc,
        icon: Icons.trending_up,
        colors: [Colors.teal, Colors.green],
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language Selection moved to top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final currentLocale = ref.watch(languageProvider);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  Text(
                    AppLocalizations.of(context)!.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingS),
                  
                  Text(
                    AppLocalizations.of(context)!.appTagline,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.3),
                  
                  const Spacer(),
                  
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final feature = features[index];
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _currentPage == index ? 1.0 : 0.7,
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: feature.colors.map((c) => c.withOpacity(0.2)).toList(),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  feature.icon,
                                  color: feature.colors[0],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              Text(
                                feature.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                feature.description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.spacingS),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      features.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  CustomButton(
                    text: AppLocalizations.of(context)!.signUp,
                    onPressed: () => context.go('/sign-up'),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.3),
                  
                  const SizedBox(height: AppConstants.spacingS),
                  
                  Transform.scale(
                    scale: 0.95,
                    child: CustomButton(
                      text: AppLocalizations.of(context)!.signIn,
                      onPressed: () => context.go('/sign-in'),
                      isOutlined: true,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(begin: 0.3),
                  ),
                  
                  const SizedBox(height: AppConstants.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 