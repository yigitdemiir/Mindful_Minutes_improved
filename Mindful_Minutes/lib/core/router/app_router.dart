import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:async';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/meditation/presentation/screens/home_screen.dart';
import '../../features/meditation/presentation/screens/meditation_screen.dart';
import '../../features/meditation/presentation/screens/sleep_screen.dart';
import '../../features/meditation/presentation/screens/progress_screen.dart';
import '../providers/navigation_provider.dart';
import '../../features/auth/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges()
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/sign-up',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ResetPasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/verify-email',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EmailVerificationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/meditate',
          builder: (context, state) => const MeditationScreen(),
        ),
        GoRoute(
          path: '/sleep',
          builder: (context, state) => const SleepScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Handle empty location
    if (state.matchedLocation.isEmpty) {
      return '/';
    }

    final isSignedIn = FirebaseAuth.instance.currentUser != null;
    final isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    
    final isOnAuthPage = state.matchedLocation == '/' ||
        state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/sign-up' ||
        state.matchedLocation == '/reset-password';

    final isOnVerificationPage = state.matchedLocation == '/verify-email';

    // If not signed in and trying to access protected route
    if (!isSignedIn && !isOnAuthPage) {
      return '/sign-in';
    }

    // If signed in but email not verified
    if (isSignedIn && !isEmailVerified) {
      // Allow access to auth pages and verification page
      if (isOnAuthPage) {
        return '/verify-email';
      }
      if (isOnVerificationPage) {
        return null;
      }
      return '/verify-email';
    }

    // If signed in and email verified
    if (isSignedIn && isEmailVerified) {
      // Redirect from auth pages to home
      if (isOnAuthPage || isOnVerificationPage) {
        return '/home';
      }
    }

    return null;
  },
);

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final pageController = ref.watch(pageControllerProvider);

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const PageScrollPhysics(),
        onPageChanged: (index) {
          ref.read(selectedNavIndexProvider.notifier).state = index;
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/meditate');
              break;
            case 2:
              context.go('/sleep');
              break;
            case 3:
              context.go('/progress');
              break;
          }
        },
        children: const [
          HomeScreen(),
          MeditationScreen(),
          SleepScreen(),
          ProgressScreen(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              height: 65,
              backgroundColor: Colors.transparent,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 400),
              indicatorColor: Colors.white.withOpacity(0.1),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              destinations: [
                _buildNavDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: AppLocalizations.of(context)!.home,
                  isSelected: selectedIndex == 0,
                ),
                _buildNavDestination(
                  icon: Icons.self_improvement_outlined,
                  selectedIcon: Icons.self_improvement,
                  label: AppLocalizations.of(context)!.meditate,
                  isSelected: selectedIndex == 1,
                ),
                _buildNavDestination(
                  icon: Icons.bedtime_outlined,
                  selectedIcon: Icons.bedtime,
                  label: AppLocalizations.of(context)!.sleep,
                  isSelected: selectedIndex == 2,
                ),
                _buildNavDestination(
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                  label: AppLocalizations.of(context)!.progress,
                  isSelected: selectedIndex == 3,
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                ref.read(selectedNavIndexProvider.notifier).state = index;
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/meditate');
                    break;
                  case 2:
                    context.go('/sleep');
                    break;
                  case 3:
                    context.go('/progress');
                    break;
                }
                pageController.jumpToPage(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool isSelected = false,
  }) {
    return NavigationDestination(
      icon: Icon(
        icon,
        color: Colors.white.withOpacity(0.7),
        size: 24,
      ),
      selectedIcon: Container(
        child: Icon(
          selectedIcon,
          color: Colors.white,
          size: 24,
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1))
        .fade(),
      label: label,
    );
  }
} 