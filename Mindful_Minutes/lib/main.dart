import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'shared/widgets/custom_button.dart';
import 'shared/widgets/gradient_background.dart';
import 'core/router/app_router.dart';
import 'features/meditation/services/audio_service.dart';
import 'features/meditation/providers/bedtime_provider.dart';
import 'core/services/notification_service.dart';
import 'features/meditation/services/firestore_service.dart';
import 'features/meditation/providers/firestore_provider.dart';
import 'features/meditation/providers/meditation_reminder_provider.dart';
import 'core/providers/shared_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York')); // Set your default timezone
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize audio service
  final audioService = AudioService();
  await audioService.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create FirestoreService instance
  final firestoreService = FirestoreService();

  runApp(
    ProviderScope(
      overrides: [
        audioServiceProvider.overrideWithValue(audioService),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
        firestoreServiceProvider.overrideWithValue(firestoreService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize providers that need to be started immediately
    ref.watch(bedtimeProvider); // Initialize bedtime notifications
    ref.watch(meditationReminderProvider); // Initialize meditation reminders
    
    // Get current locale from language provider
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      routerConfig: goRouter,
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn().slideY(begin: 0.3),
                
                const SizedBox(height: AppConstants.spacingM),
                
                Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)).slideY(begin: 0.3),
                
                const SizedBox(height: AppConstants.spacingXXL),
                
                CustomButton(
                  text: AppConstants.getStarted,
                  onPressed: () {
                    // TODO: Navigate to home screen
                  },
                ).animate().fadeIn(delay: const Duration(milliseconds: 400)).slideY(begin: 0.3),
                
                const SizedBox(height: AppConstants.spacingL),
                
                CustomButton(
                  text: 'Sign In',
                  onPressed: () {
                    // TODO: Navigate to sign in screen
                  },
                  isOutlined: true,
                ).animate().fadeIn(delay: const Duration(milliseconds: 600)).slideY(begin: 0.3),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
