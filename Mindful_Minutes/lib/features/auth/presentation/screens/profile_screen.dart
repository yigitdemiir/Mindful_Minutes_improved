import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (mounted) {
        // Use pushReplacement instead of go to avoid navigator state issues
        context.pushReplacement('/sign-in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation of build method
  }
} 