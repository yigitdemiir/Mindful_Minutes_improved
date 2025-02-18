import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be initialized in main.dart');
});

// Provider for NotificationService instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Should be initialized in main.dart');
}); 