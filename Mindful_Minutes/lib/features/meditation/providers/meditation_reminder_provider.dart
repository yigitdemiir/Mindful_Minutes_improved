import 'package:flutter_bigapp/core/providers/shared_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';

class MeditationReminderNotifier extends StateNotifier<bool> {
  final NotificationService _notificationService;

  MeditationReminderNotifier(this._notificationService) : super(true) {
    // Schedule meditation reminder on initialization
    _scheduleMeditationReminder();
  }

  Future<void> _scheduleMeditationReminder() async {
    try {
      await _notificationService.scheduleDailyMeditationReminder();
      state = true;
    } catch (e) {
      print('Error scheduling meditation reminder: $e');
      state = false;
    }
  }

  Future<void> toggleReminder(bool enabled) async {
    if (enabled) {
      await _scheduleMeditationReminder();
    } else {
      // TODO: Cancel reminder if needed
      state = false;
    }
  }
}

final meditationReminderProvider = StateNotifierProvider<MeditationReminderNotifier, bool>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return MeditationReminderNotifier(notificationService);
}); 