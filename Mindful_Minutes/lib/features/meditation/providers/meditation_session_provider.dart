import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

class MeditationSessionState {
  final int remainingTime;
  final bool isPlaying;
  final String backgroundMusic;
  final double musicVolume;
  final bool isMuted;
  final int initialDuration;
  final bool isCompleted;

  const MeditationSessionState({
    required this.remainingTime,
    required this.isPlaying,
    required this.backgroundMusic,
    required this.musicVolume,
    required this.isMuted,
    required this.initialDuration,
    required this.isCompleted,
  });

  factory MeditationSessionState.initial({
    required int durationInSeconds,
    required String backgroundMusic,
  }) {
    return MeditationSessionState(
      remainingTime: durationInSeconds,
      isPlaying: false,
      backgroundMusic: backgroundMusic,
      musicVolume: 0.7,
      isMuted: false,
      initialDuration: durationInSeconds,
      isCompleted: false,
    );
  }

  MeditationSessionState copyWith({
    int? remainingTime,
    bool? isPlaying,
    String? backgroundMusic,
    double? musicVolume,
    bool? isMuted,
    int? initialDuration,
    bool? isCompleted,
  }) {
    return MeditationSessionState(
      remainingTime: remainingTime ?? this.remainingTime,
      isPlaying: isPlaying ?? this.isPlaying,
      backgroundMusic: backgroundMusic ?? this.backgroundMusic,
      musicVolume: musicVolume ?? this.musicVolume,
      isMuted: isMuted ?? this.isMuted,
      initialDuration: initialDuration ?? this.initialDuration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class MeditationSessionNotifier extends StateNotifier<MeditationSessionState> {
  final AudioService _audioService;
  Timer? _timer;

  MeditationSessionNotifier(
    this._audioService, {
    required int durationInSeconds,
    required String backgroundMusic,
  }) : super(MeditationSessionState.initial(
          durationInSeconds: durationInSeconds,
          backgroundMusic: backgroundMusic,
        ));

  Future<void> startSession() async {
    if (state.isPlaying) return;

    try {
      // Update state immediately for UI feedback
      state = state.copyWith(isPlaying: true, isCompleted: false);
      
      // Start timer immediately
      _startTimer();

      // Handle audio last
      if (!state.isMuted) {
        await _audioService.stopBackground();
        await _audioService.playBackgroundSound(state.backgroundMusic);
        await _audioService.setBackgroundVolume(state.musicVolume);
      }
    } catch (e) {
      print('Error starting session: $e');
      _timer?.cancel();
      await _audioService.stopBackground();
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> pauseSession() async {
    if (!state.isPlaying) return;

    try {
      // Update state immediately for UI feedback
      state = state.copyWith(isPlaying: false);
      
      // Pause timer
      _timer?.cancel();
      
      // Pause audio
      if (!state.isMuted) {
        await _audioService.pauseBackground();
      }
    } catch (e) {
      print('Error pausing session: $e');
    }
  }

  Future<void> resumeSession() async {
    if (state.isPlaying) return;

    try {
      // Update state immediately for UI feedback
      state = state.copyWith(isPlaying: true);
      
      // Resume timer
      _startTimer();
      
      // Resume audio
      if (!state.isMuted) {
        // Check if we need to load the sound first
        await _audioService.playBackgroundSound(state.backgroundMusic);
        await _audioService.setBackgroundVolume(state.musicVolume);
      }
    } catch (e) {
      print('Error resuming session: $e');
      _timer?.cancel();
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> resetSession() async {
    _timer?.cancel();
    await _audioService.stopBackground();
    state = MeditationSessionState.initial(
      durationInSeconds: state.initialDuration,
      backgroundMusic: state.backgroundMusic,
    );
  }

  Future<void> setBackgroundMusic(String music) async {
    if (music != state.backgroundMusic) {
      try {
        final wasPlaying = state.isPlaying;
        
        // Stop current playback
        await _audioService.stopBackground();
        
        // Update state with new music
        state = state.copyWith(backgroundMusic: music);
        
        // Only start playing if the session was already playing and not muted
        if (wasPlaying && !state.isMuted) {
          await _audioService.playBackgroundSound(music);
          await _audioService.setBackgroundVolume(state.musicVolume);
        }
      } catch (e) {
        print('Error changing background music: $e');
        // Revert to previous state if there's an error
        state = state.copyWith(backgroundMusic: state.backgroundMusic);
      }
    }
  }

  Future<void> setMusicVolume(double volume) async {
    state = state.copyWith(musicVolume: volume);
    if (state.isPlaying && !state.isMuted) {
      await _audioService.setBackgroundVolume(volume);
    }
  }

  Future<void> toggleMute() async {
    final newMuted = !state.isMuted;
    state = state.copyWith(isMuted: newMuted);
    if (state.isPlaying) {
      if (newMuted) {
        await _audioService.pauseBackground();
      } else {
        await _audioService.resumeBackground();
        await _audioService.setBackgroundVolume(state.musicVolume);
      }
    }
  }

  void _startTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Create new timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Skip countdown for infinite duration sessions (remainingTime == -1)
      if (state.remainingTime == -1) {
        return;
      }
      
      if (state.remainingTime > 0) {
        state = state.copyWith(
          remainingTime: state.remainingTime - 1,
        );
      } else {
        timer.cancel();
        _audioService.stopBackground();
        state = state.copyWith(
          isPlaying: false,
          isCompleted: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

class MeditationSessionConfig {
  final String title;
  final int durationInSeconds;
  final String backgroundMusic;

  const MeditationSessionConfig({
    required this.title,
    required this.durationInSeconds,
    required this.backgroundMusic,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeditationSessionConfig &&
        other.title == title &&
        other.durationInSeconds == durationInSeconds &&
        other.backgroundMusic == backgroundMusic;
  }

  @override
  int get hashCode => Object.hash(title, durationInSeconds, backgroundMusic);
}

final currentSessionConfigProvider = StateProvider<MeditationSessionConfig?>((ref) => null);

final meditationSessionProvider = StateNotifierProvider.family<MeditationSessionNotifier, MeditationSessionState, MeditationSessionConfig>(
  (ref, config) => MeditationSessionNotifier(
    ref.watch(audioServiceProvider),
    durationInSeconds: config.durationInSeconds,
    backgroundMusic: config.backgroundMusic,
  ),
); 