import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/providers/shared_providers.dart';

class BedtimeNotifier extends StateNotifier<TimeOfDay?> {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;
  static const String _bedtimeHourKey = 'bedtime_hour';
  static const String _bedtimeMinuteKey = 'bedtime_minute';

  BedtimeNotifier(this._prefs, this._notificationService) : super(null) {
    // Load saved bedtime on initialization
    final savedHour = _prefs.getInt(_bedtimeHourKey);
    final savedMinute = _prefs.getInt(_bedtimeMinuteKey);
    
    if (savedHour != null && savedMinute != null) {
      state = TimeOfDay(hour: savedHour, minute: savedMinute);
    } else {
      // Default to 10:30 PM if no saved time
      state = const TimeOfDay(hour: 22, minute: 30);
    }
    _saveBedtime(state!);
    _scheduleBedtimeNotification(state!);
  }

  Future<void> setBedtime(TimeOfDay time) async {
    state = time;
    await _saveBedtime(time);
    await _scheduleBedtimeNotification(time);
  }

  Future<void> _saveBedtime(TimeOfDay time) async {
    await _prefs.setInt(_bedtimeHourKey, time.hour);
    await _prefs.setInt(_bedtimeMinuteKey, time.minute);
  }

  Future<void> _scheduleBedtimeNotification(TimeOfDay time) async {
    await _notificationService.scheduleBedtimeNotification(time);
  }
}

final bedtimeProvider = StateNotifierProvider<BedtimeNotifier, TimeOfDay?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return BedtimeNotifier(prefs, notificationService);
}); 