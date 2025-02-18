import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';

class MeditationCard extends StatelessWidget {
  final String title;
  final String duration;
  final String category;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isPremium;

  const MeditationCard({
    super.key,
    required this.title,
    required this.duration,
    required this.category,
    required this.onTap,
    this.imageUrl,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Stack(
            children: [
              // Background Image
              if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              
              // Gradient Overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.surface.withOpacity(0.8),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium Badge
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: AppConstants.spacingXXS,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().slideX(
                            begin: 0.5,
                            end: 0,
                            duration: AppConstants.animFast,
                          ),
                    
                    const Spacer(),
                    
                    // Category
                    Text(
                      category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: AppConstants.animFast),
                    
                    const SizedBox(height: AppConstants.spacingXS),
                    
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: AppConstants.animMedium),
                    
                    const SizedBox(height: AppConstants.spacingXS),
                    
                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          duration,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: AppConstants.animSlow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 