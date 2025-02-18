import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../providers/meditation_session_provider.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/meditation_library_provider.dart';
import '../../providers/progress_provider.dart';
import '../../models/meditation.dart';
import '../../../auth/services/auth_service.dart';
import '../widgets/session_completion_dialog.dart';
import '../widgets/volume_control_sheet.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeditationSessionScreen extends ConsumerStatefulWidget {
  final String title;
  final String duration;
  final String backgroundMusic;

  const MeditationSessionScreen({
    super.key,
    required this.title,
    required this.duration,
    required this.backgroundMusic,
  });

  @override
  ConsumerState<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends ConsumerState<MeditationSessionScreen> {
  late final MeditationSessionConfig _sessionConfig;
  bool _showTip = true;
  int _currentTipIndex = 0;
  
  List<String> _getMeditationTips(BuildContext context) {
    return [
      AppLocalizations.of(context)!.meditationTip1,
      AppLocalizations.of(context)!.meditationTip2,
      AppLocalizations.of(context)!.meditationTip3,
      AppLocalizations.of(context)!.meditationTip4,
      AppLocalizations.of(context)!.meditationTip5,
      AppLocalizations.of(context)!.meditationTip6,
    ];
  }

  @override
  void initState() {
    super.initState();
    // Handle infinite duration sessions and parse regular duration strings
    final durationInSeconds = widget.duration == '∞' 
        ? -1  // Use -1 to represent infinite duration
        : int.parse(widget.duration.split(' ')[0]) * 60; // Minutes to seconds for regular meditations
    
    _sessionConfig = MeditationSessionConfig(
      title: widget.title,
      durationInSeconds: durationInSeconds,
      backgroundMusic: widget.backgroundMusic,
    );

    // Start tip rotation timer
    _startTipRotation();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _getMeditationTips(context).length;
        });
        _startTipRotation();
      }
    });
  }

  Future<void> _saveCompletedSession() async {
    final authService = ref.read(authServiceProvider);
    
    if (authService.currentUser == null) {
      if (!mounted) return;
      
      // Show sign in dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text('Please sign in to save your meditation progress.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.go('/sign-in'); // Navigate to sign in screen
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      
      // Get the original meditation from the library
      final meditationLibrary = ref.read(meditationLibraryProvider);
      final originalMeditation = meditationLibrary.firstWhere(
        (m) => m.title == widget.title,
        orElse: () => Meditation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: widget.title,
          description: 'Completed meditation session',
          durationInMinutes: int.parse(widget.duration.split(' ')[0]),
          audioFile: widget.backgroundMusic,
          category: MeditationCategory.all,
          icon: Icons.self_improvement,
          accentColor: Colors.blue,
        ),
      );

      // Create completed meditation with original details
      final completedMeditation = Meditation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: originalMeditation.title,
        description: originalMeditation.description,
        durationInMinutes: originalMeditation.durationInMinutes,
        audioFile: originalMeditation.audioFile,
        category: originalMeditation.category,
        icon: originalMeditation.icon,
        accentColor: originalMeditation.accentColor,
        isPremium: originalMeditation.isPremium,
      );
      
      await firestoreService.saveCompletedMeditation(completedMeditation);
      
      // Invalidate providers to refresh the UI
      ref.invalidate(streakProvider);
      ref.invalidate(weeklyProgressProvider);
      ref.invalidate(achievementsProvider);
      
    } catch (e) {
      print('Error saving completed session: $e');
      if (!mounted) return;
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save meditation progress: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the session state when leaving the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(meditationSessionProvider(_sessionConfig));
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(meditationSessionProvider(_sessionConfig));

    // Show completion dialog when session is completed
    if (sessionState.isCompleted) {
      // Save completed session to Firestore
      _saveCompletedSession();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SessionCompletionDialog(
            sessionDurationInSeconds: sessionState.initialDuration,
            backgroundMusic: sessionState.backgroundMusic,
            onRestart: () async {
              Navigator.of(context).pop();
              final notifier = ref.read(meditationSessionProvider(_sessionConfig).notifier);
              await notifier.resetSession();
              await notifier.startSession();
            },
            onClose: () {
              Navigator.of(context).pop(); // Close dialog
              ref.read(meditationSessionProvider(_sessionConfig).notifier).resetSession(); // Reset session state
              Navigator.of(context).pop(); // Close meditation screen
            },
          ),
        );
      });
    }

    return WillPopScope(
      onWillPop: () async {
        // Reset session state when leaving the screen
        ref.read(meditationSessionProvider(_sessionConfig).notifier).resetSession();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            // Animated Background
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sessionState.isPlaying
                        ? const Color(0xFF2C1F54).withOpacity(0.95)
                        : const Color(0xFF2C1F54).withOpacity(0.8),
                    sessionState.isPlaying
                        ? const Color(0xFF1E133B).withOpacity(0.98)
                        : const Color(0xFF1E133B).withOpacity(0.85),
                  ],
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            ref.read(meditationSessionProvider(_sessionConfig).notifier).resetSession();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Meditation tip
                  if (_showTip)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: sessionState.isPlaying ? 0.7 : 0,
                        child: Text(
                          _getMeditationTips(context)[_currentTipIndex],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Timer Display
                  Text(
                    _formatTime(sessionState.remainingTime),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // Play/Pause button with ripple effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: sessionState.isPlaying ? 100 : 90,
                        height: sessionState.isPlaying ? 100 : 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final sessionState = ref.watch(meditationSessionProvider(_sessionConfig));
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                final notifier = ref.read(meditationSessionProvider(_sessionConfig).notifier);
                                if (sessionState.isPlaying) {
                                  notifier.pauseSession();
                                } else if (sessionState.remainingTime < sessionState.initialDuration) {
                                  notifier.resumeSession();
                                } else {
                                  notifier.startSession();
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      sessionState.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      key: ValueKey(sessionState.isPlaying),
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Controls with enhanced volume slider
                  Column(
                    children: [
                      // Volume Controls
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    sessionState.isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    ref.read(meditationSessionProvider(_sessionConfig).notifier).toggleMute();
                                  },
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white24,
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 14,
                                      ),
                                    ),
                                    child: Slider(
                                      value: sessionState.musicVolume,
                                      onChanged: (value) {
                                        ref.read(meditationSessionProvider(_sessionConfig).notifier)
                                            .setMusicVolume(value);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Sound ambiance indicator
                            Text(
                              '${AppLocalizations.of(context)!.playing} ${widget.backgroundMusic.split('/').last.replaceAll('_', ' ').replaceAll('.mp3', '')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds == -1) {
      return '∞';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 