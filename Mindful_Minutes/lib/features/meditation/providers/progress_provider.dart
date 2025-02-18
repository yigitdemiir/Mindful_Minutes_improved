import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../../auth/services/auth_service.dart';
import 'firestore_provider.dart';

// Streak Provider
final streakProvider = FutureProvider<Map<String, int>>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return {'current': 0, 'best': 0};
      final firestoreService = ref.watch(firestoreServiceProvider);
      final currentStreak = await firestoreService.getCurrentStreak();
      final bestStreak = await firestoreService.getBestStreak();
      return {
        'current': currentStreak,
        'best': bestStreak,
      };
    },
    loading: () async => {'current': 0, 'best': 0},
    error: (_, __) async => {'current': 0, 'best': 0},
  );
});

// Weekly Progress Provider
final weeklyProgressProvider = StreamProvider<Map<String, int>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value({});
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getWeeklyProgress();
    },
    loading: () => Stream.value({}),
    error: (_, __) => Stream.value({}),
  );
});

// Achievements Provider
final achievementsProvider = StreamProvider<Map<String, int>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value({});
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getAchievements();
    },
    loading: () => Stream.value({}),
    error: (_, __) => Stream.value({}),
  );
}); 