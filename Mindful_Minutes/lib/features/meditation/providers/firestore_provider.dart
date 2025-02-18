import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/meditation.dart';
import '../../auth/services/auth_service.dart';

// Provider for FirestoreService instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider for recent meditations stream
final recentMeditationsStreamProvider = StreamProvider<List<Meditation>>((ref) {
  // Watch auth state changes
  final authState = ref.watch(authStateProvider);
  
  // Return empty list if not authenticated
  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getRecentMeditations();
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Provider for total meditation minutes
final totalMeditationMinutesProvider = FutureProvider<int>((ref) {
  // Watch auth state changes
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return 0;
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getTotalMeditationMinutes();
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider for total meditation sessions
final totalSessionsProvider = FutureProvider<int>((ref) {
  // Watch auth state changes
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return 0;
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getTotalSessions();
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider for current streak
final currentStreakProvider = FutureProvider<int>((ref) {
  // Watch auth state changes
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return 0;
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getCurrentStreak();
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}); 