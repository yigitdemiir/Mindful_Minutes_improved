import 'package:flutter/material.dart';

enum MeditationCategory {
  all,
  morning,
  focus,
  anxiety,
  evening,
  stress,
  sleep,
  calming,
  relaxation
}

class Meditation {
  final String id;
  final String title;
  final String description;
  final int durationInMinutes;
  final String audioFile;
  final MeditationCategory category;
  final IconData icon;
  final bool isPremium;
  final Color accentColor;

  const Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.durationInMinutes,
    required this.audioFile,
    required this.category,
    required this.icon,
    this.isPremium = false,
    required this.accentColor,
  });

  String get durationText => '$durationInMinutes min';
}

// Sample meditation data
final List<Meditation> sampleMeditations = [
  // Morning Meditations
  Meditation(
    id: 'morning-birds',
    title: 'Morning Birds',
    description: 'Wake up to the peaceful sounds of nature',
    durationInMinutes: 12,
    audioFile: 'onlyBirds',
    category: MeditationCategory.morning,
    icon: Icons.wb_sunny_outlined,
    accentColor: Colors.orange,
  ),
  Meditation(
    id: 'morning-pad',
    title: 'Morning Serenity',
    description: 'Begin your day with soothing pad sounds',
    durationInMinutes: 15,
    audioFile: 'padsound',
    category: MeditationCategory.morning,
    icon: Icons.wb_sunny_outlined,
    accentColor: Colors.orange,
  ),
  Meditation(
    id: 'morning-calm',
    title: 'Morning Calm',
    description: 'Start your day with crystal bowls',
    durationInMinutes: 10,
    audioFile: 'crystal_bowls',
    category: MeditationCategory.morning,
    icon: Icons.wb_sunny_outlined,
    accentColor: Colors.orange,
  ),

  // Focus Meditations
  Meditation(
    id: 'focus-piano',
    title: 'Piano Focus',
    description: 'Enhance your focus with calming piano melodies',
    durationInMinutes: 22,
    audioFile: 'piano',
    category: MeditationCategory.focus,
    icon: Icons.lens_outlined,
    accentColor: Colors.blue,
  ),
  Meditation(
    id: 'focus-flow',
    title: 'Focus Flow',
    description: 'Enhance concentration with river sounds',
    durationInMinutes: 20,
    audioFile: 'river',
    category: MeditationCategory.focus,
    icon: Icons.lens_outlined,
    accentColor: Colors.blue,
  ),
  Meditation(
    id: 'deep-focus',
    title: 'Deep Focus',
    description: 'Concentrate with green noise',
    durationInMinutes: 25,
    audioFile: 'greenNoise',
    category: MeditationCategory.focus,
    icon: Icons.lens_outlined,
    accentColor: Colors.blue,
    isPremium: true,
  ),

  // Anxiety Release Meditations
  Meditation(
    id: 'anxiety-atmospheric',
    title: 'Atmospheric Journey',
    description: 'Release stress with atmospheric soundscapes',
    durationInMinutes: 18,
    audioFile: 'atmospheric_landscape',
    category: MeditationCategory.anxiety,
    icon: Icons.healing_outlined,
    accentColor: Colors.teal,
  ),
  Meditation(
    id: 'anxiety-release',
    title: 'Forest Bath',
    description: 'Find calm in forest sounds',
    durationInMinutes: 15,
    audioFile: 'forest',
    category: MeditationCategory.anxiety,
    icon: Icons.healing_outlined,
    accentColor: Colors.teal,
  ),
  Meditation(
    id: 'anxiety-calm',
    title: 'Ocean Calm',
    description: 'Release anxiety with ocean waves',
    durationInMinutes: 20,
    audioFile: 'ocean',
    category: MeditationCategory.anxiety,
    icon: Icons.healing_outlined,
    accentColor: Colors.teal,
    isPremium: true,
  ),

  // Evening Meditations
  Meditation(
    id: 'evening-chimes',
    title: 'Evening Chimes',
    description: 'Relax with gentle chiming sounds',
    durationInMinutes: 17,
    audioFile: 'eveningChimes',
    category: MeditationCategory.evening,
    icon: Icons.nightlight_outlined,
    accentColor: Colors.indigo,
  ),
  Meditation(
    id: 'evening-peace',
    title: 'Rain Peace',
    description: 'Wind down with gentle rain',
    durationInMinutes: 15,
    audioFile: 'new_rain',
    category: MeditationCategory.evening,
    icon: Icons.nightlight_outlined,
    accentColor: Colors.indigo,
  ),
  Meditation(
    id: 'evening-wind',
    title: 'Wind Release',
    description: 'Drift off with wind sounds',
    durationInMinutes: 20,
    audioFile: 'wind',
    category: MeditationCategory.evening,
    icon: Icons.nightlight_outlined,
    accentColor: Colors.indigo,
    isPremium: true,
  ),
]; 