import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meditation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirestoreService() {
    // No need for auth state listener anymore
  }

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Convert Firestore document to Meditation object
  Meditation _convertToMeditation(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meditation(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      durationInMinutes: data['durationInMinutes'] ?? 0,
      audioFile: data['audioFile'] ?? '',
      category: MeditationCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => MeditationCategory.all,
      ),
      icon: IconData(
        data['iconCodePoint'] ?? Icons.self_improvement.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      isPremium: data['isPremium'] ?? false,
      accentColor: Color(data['accentColor'] ?? Colors.blue.value),
    );
  }

  // Convert Meditation object to Firestore document
  Map<String, dynamic> _convertFromMeditation(Meditation meditation) {
    return {
      'title': meditation.title,
      'description': meditation.description,
      'durationInMinutes': meditation.durationInMinutes,
      'audioFile': meditation.audioFile,
      'category': meditation.category.toString(),
      'iconCodePoint': meditation.icon.codePoint,
      'isPremium': meditation.isPremium,
      'accentColor': meditation.accentColor.value,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  // Save completed meditation session
  Future<void> saveCompletedMeditation(Meditation meditation) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('completed_meditations')
          .add(_convertFromMeditation(meditation));
    } catch (e) {
      print('Error saving completed meditation: $e');
      rethrow;
    }
  }

  // Get recent meditation sessions
  Stream<List<Meditation>> getRecentMeditations() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('completed_meditations')
        .orderBy('timestamp', descending: true)
        .limit(20) // Increased limit to ensure we have enough unique sessions
        .snapshots()
        .map((snapshot) {
          final meditations = snapshot.docs
            .where((doc) => doc.data()['timestamp'] != null)
            .map((doc) => _convertToMeditation(doc))
            .toList();

          // Create a map to store unique meditations by title
          final uniqueMeditations = <String, Meditation>{};
          
          // Keep only the most recent session for each meditation title
          for (var meditation in meditations) {
            if (!uniqueMeditations.containsKey(meditation.title)) {
              uniqueMeditations[meditation.title] = meditation;
            }
          }

          // Return the first 5 unique meditations
          return uniqueMeditations.values.take(5).toList();
        });
  }

  // Get total meditation minutes for a user
  Future<int> getTotalMeditationMinutes() async {
    if (_userId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('completed_meditations')
          .get();

      return querySnapshot.docs.fold<int>(
        0,
        (total, doc) => total + ((doc.data()['durationInMinutes'] as num?)?.toInt() ?? 0),
      );
    } catch (e) {
      print('Error getting total meditation minutes: $e');
      return 0;
    }
  }

  // Get total number of meditation sessions
  Future<int> getTotalSessions() async {
    if (_userId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('completed_meditations')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting total sessions: $e');
      return 0;
    }
  }

  // Get current streak
  Future<int> getCurrentStreak() async {
    if (_userId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('completed_meditations')
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      Set<String> meditationDays = {};
      DateTime? lastMeditationDate;
      
      // First, collect all unique meditation days
      for (var doc in querySnapshot.docs) {
        final timestamp = doc.data()['timestamp'] as Timestamp?;
        if (timestamp == null) continue;

        final date = timestamp.toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        final dateKey = '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
        
        meditationDays.add(dateKey);
        
        if (lastMeditationDate == null || dateOnly.isAfter(lastMeditationDate)) {
          lastMeditationDate = dateOnly;
        }
      }

      // If no meditation today or yesterday, streak is broken
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      
      if (!meditationDays.contains(todayKey) && !meditationDays.contains(yesterdayKey)) {
        return 0;
      }

      // Calculate streak by counting consecutive days backwards
      int streak = 0;
      DateTime checkDate = meditationDays.contains(todayKey) ? today : yesterday;
      
      while (true) {
        final checkKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
        if (!meditationDays.contains(checkKey)) {
          break;
        }
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Update best streak if current is higher
      await updateBestStreak(streak);

      return streak;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  // Get best streak
  Future<int> getBestStreak() async {
    if (_userId == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      return (doc.data()?['bestStreak'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error getting best streak: $e');
      return 0;
    }
  }

  // Update best streak if current is higher
  Future<void> updateBestStreak(int currentStreak) async {
    if (_userId == null) return;

    try {
      final currentBest = await getBestStreak();
      if (currentStreak > currentBest) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .set({'bestStreak': currentStreak}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating best streak: $e');
    }
  }

  // Get weekly progress
  Stream<Map<String, int>> getWeeklyProgress() {
    if (_userId == null) return Stream.value({});

    // Get the start of the current week (Monday)
    final now = DateTime.now();
    var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('completed_meditations')
        .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
        .snapshots()
        .map((snapshot) {
          final weekProgress = <String, int>{};
          
          // Initialize all days of the week with 0
          for (var i = 0; i < 7; i++) {
            final day = startOfWeek.add(Duration(days: i));
            final dayKey = '${day.year}-${day.month}-${day.day}';
            weekProgress[dayKey] = 0;
          }

          // Sum up minutes for each day
          for (var doc in snapshot.docs) {
            final timestamp = doc.data()['timestamp'] as Timestamp;
            final date = timestamp.toDate();
            final dayKey = '${date.year}-${date.month}-${date.day}';
            weekProgress[dayKey] = (weekProgress[dayKey] ?? 0) + (doc.data()['durationInMinutes'] as num).toInt();
          }

          return weekProgress;
        });
  }

  // Get achievements progress
  Stream<Map<String, int>> getAchievements() {
    if (_userId == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('completed_meditations')
        .snapshots()
        .asyncMap((snapshot) async {
          // Calculate basic achievement metrics
          int totalSessions = snapshot.docs.length;
          int totalMinutes = 0;
          int earlyBirdSessions = 0;
          int nightOwlSessions = 0;
          int perfectComboDays = 0;
          int deepFocusSessions = 0;

          // Track days with both morning and evening sessions
          Map<String, Set<String>> dailyTimeSlots = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final minutes = (data['durationInMinutes'] as num).toInt();
            final timestamp = data['timestamp'] as Timestamp;
            final dateTime = timestamp.toDate();
            final hour = dateTime.hour;
            final dayKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

            totalMinutes += minutes;

            // Early Bird: 5 AM - 9 AM
            if (hour >= 5 && hour < 9) {
              earlyBirdSessions++;
              dailyTimeSlots.putIfAbsent(dayKey, () => {}).add('morning');
            }
            // Night Owl: 10 PM - 12 AM
            if (hour >= 22) {
              nightOwlSessions++;
              dailyTimeSlots.putIfAbsent(dayKey, () => {}).add('evening');
            }
            // Deep Focus: 20 minutes or more
            if (minutes >= 20) {
              deepFocusSessions++;
            }
          }

          // Count days with both morning and evening sessions
          for (var slots in dailyTimeSlots.values) {
            if (slots.contains('morning') && slots.contains('evening')) {
              perfectComboDays++;
            }
          }

          return {
            'totalSessions': totalSessions,
            'totalMinutes': totalMinutes,
            'earlyBirdSessions': earlyBirdSessions,
            'nightOwlSessions': nightOwlSessions,
            'perfectComboDays': perfectComboDays,
            'deepFocusSessions': deepFocusSessions,
          };
        });
  }
} 