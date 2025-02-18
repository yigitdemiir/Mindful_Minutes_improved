import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

final pageControllerProvider = Provider<PageController>((ref) {
  final controller = PageController(initialPage: ref.watch(selectedNavIndexProvider));
  ref.onDispose(() => controller.dispose());
  return controller;
}); 