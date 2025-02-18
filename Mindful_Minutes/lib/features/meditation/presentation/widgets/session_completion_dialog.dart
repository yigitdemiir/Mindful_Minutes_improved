import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class SessionCompletionDialog extends StatelessWidget {
  final int sessionDurationInSeconds;
  final String backgroundMusic;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const SessionCompletionDialog({
    super.key,
    required this.sessionDurationInSeconds,
    required this.backgroundMusic,
    required this.onRestart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Completion Icon
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
            ).animate().scale(),

            const SizedBox(height: AppConstants.spacingL),

            // Congratulations Text
            Text(
              'Session Complete',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ).animate().fadeIn().slideY(begin: 0.3),

            const SizedBox(height: AppConstants.spacingM),

            Text(
              'Great job completing your meditation session!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

            const SizedBox(height: AppConstants.spacingL),

            // Statistics
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    'Duration',
                    '${(sessionDurationInSeconds / 60).round()} minutes',
                    Icons.timer_outlined,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildStatRow(
                    context,
                    'Background',
                    _formatMusicName(backgroundMusic),
                    Icons.music_note_outlined,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

            const SizedBox(height: AppConstants.spacingL),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay),
                  label: const Text('Restart'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ],
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }

  String _formatMusicName(String filename) {
    // Remove file extension and convert to title case
    final name = filename.split('.').first.replaceAll('_', ' ');
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
} 