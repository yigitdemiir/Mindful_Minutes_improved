import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meditation.dart';

class MeditationLibraryNotifier extends StateNotifier<List<Meditation>> {
  MeditationLibraryNotifier() : super(sampleMeditations);

  List<Meditation> getMeditationsByCategory(MeditationCategory category) {
    if (category == MeditationCategory.all) return state;
    return state.where((meditation) => meditation.category == category).toList();
  }

  Meditation? getMeditationById(String id) {
    try {
      return state.firstWhere((meditation) => meditation.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Meditation> getRecentMeditations() {
    // TODO: Implement actual recent meditations tracking
    return state.take(3).toList();
  }

  List<Meditation> getRecommendedMeditations() {
    // TODO: Implement actual recommendations algorithm
    return state.where((meditation) => !meditation.isPremium).take(2).toList();
  }

  Meditation getQuickStartMeditation() {
    final hour = DateTime.now().hour;
    
    // Early morning (5-9): Morning meditations
    if (hour >= 5 && hour < 9) {
      final morningMeditations = state.where((m) => m.category == MeditationCategory.morning).toList();
      if (morningMeditations.isNotEmpty) {
        return morningMeditations[DateTime.now().microsecond % morningMeditations.length];
      }
    }
    
    // Evening (18-23): Evening meditations
    if (hour >= 18 || hour < 23) {
      final eveningMeditations = state.where((m) => m.category == MeditationCategory.evening).toList();
      if (eveningMeditations.isNotEmpty) {
        return eveningMeditations[DateTime.now().microsecond % eveningMeditations.length];
      }
    }
    
    // Night (23-5): Evening meditations for night time
    if (hour >= 23 || hour < 5) {
      final eveningMeditations = state.where((m) => m.category == MeditationCategory.evening).toList();
      if (eveningMeditations.isNotEmpty) {
        return eveningMeditations[DateTime.now().microsecond % eveningMeditations.length];
      }
    }
    
    // Default: Return a random meditation
    return state[DateTime.now().microsecond % state.length];
  }
}

final meditationLibraryProvider =
    StateNotifierProvider<MeditationLibraryNotifier, List<Meditation>>(
  (ref) => MeditationLibraryNotifier(),
);

final meditationsByCategoryProvider =
    Provider.family<List<Meditation>, MeditationCategory>((ref, category) {
  final library = ref.watch(meditationLibraryProvider.notifier);
  return library.getMeditationsByCategory(category);
});

final recentMeditationsProvider = Provider<List<Meditation>>((ref) {
  final library = ref.watch(meditationLibraryProvider.notifier);
  return library.getRecentMeditations();
});

final recommendedMeditationsProvider = Provider<List<Meditation>>((ref) {
  final library = ref.watch(meditationLibraryProvider.notifier);
  return library.getRecommendedMeditations();
}); 