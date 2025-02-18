import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  final AudioPlayer _backgroundPlayer;
  bool _isInitialized = false;
  static bool _isGloballyInitialized = false;

  AudioService() : _backgroundPlayer = AudioPlayer();

  Future<void> initialize() async {
    if (_isInitialized) {
      await _backgroundPlayer.stop();
      return;
    }

    try {
      if (!_isGloballyInitialized) {
        // Initialize background playback first
        await JustAudioBackground.init(
          androidNotificationChannelId: 'com.example.flutter_bigapp.meditation',
          androidNotificationChannelName: 'Meditation',
          androidNotificationOngoing: true,
          androidShowNotificationBadge: true,
        );

        // Configure audio session
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        ));

        _isGloballyInitialized = true;
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing audio service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> playBackgroundSound(String soundName) async {
    try {
      // Ensure initialization
      await initialize();

      // Remove any .mp3 extension
      soundName = soundName.replaceAll('.mp3', '');
      
      // Determine the correct directory based on the sound name prefix
      String directory = soundName.startsWith('sleep_') ? 'background' : 'meditations';
      String assetPath = 'assets/sounds/$directory/$soundName.mp3';

      print('Attempting to play sound from path: $assetPath'); // Debug log
      
      // Create audio source with MediaItem tag
      final audioSource = AudioSource.asset(
        assetPath,
        tag: MediaItem(
          id: soundName,
          title: 'Meditation Sound',
          artist: 'Meditation App',
          artUri: null,
        ),
      );
      
      // Reset the player before setting new source
      await _backgroundPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 100)); // Add small delay
      await _backgroundPlayer.setAudioSource(audioSource);
      await _backgroundPlayer.setLoopMode(LoopMode.one);
      await _backgroundPlayer.play();
    } catch (e) {
      print('Error playing background sound: $e');
      _isInitialized = false; // Reset initialization state on error
      rethrow;
    }
  }

  Future<void> stopBackground() async {
    try {
      await _backgroundPlayer.stop();
      _isInitialized = false; // Reset initialization state
    } catch (e) {
      print('Error stopping background sound: $e');
      rethrow;
    }
  }

  Future<void> pauseBackground() async {
    try {
      await _backgroundPlayer.pause();
    } catch (e) {
      print('Error pausing background sound: $e');
      rethrow;
    }
  }

  Future<void> resumeBackground() async {
    try {
      await _backgroundPlayer.play();
    } catch (e) {
      print('Error resuming background sound: $e');
      rethrow;
    }
  }

  Future<void> setBackgroundVolume(double volume) async {
    try {
      await _backgroundPlayer.setVolume(volume);
    } catch (e) {
      print('Error setting background volume: $e');
      rethrow;
    }
  }

  Future<void> seekTo(int milliseconds) async {
    try {
      await _backgroundPlayer.seek(Duration(milliseconds: milliseconds));
      // Ensure loop mode is maintained after seeking
      await _backgroundPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      print('Error seeking audio: $e');
      rethrow;
    }
  }

  void dispose() {
    _backgroundPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}); 