import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget? child;
  final bool useAltColors;

  const GradientBackground({
    super.key,
    this.child,
    this.useAltColors = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.6, 1.0],
          colors: useAltColors
              ? [
                  const Color(0xFF1A1B35),
                  const Color(0xFF232347),
                  const Color(0xFF1A1B35),
                  const Color(0xFF15162D),
                ]
              : [
                  const Color(0xFF1A1B35),
                  const Color(0xFF232347),
                  const Color(0xFF1A1B35),
                  const Color(0xFF15162D),
                ],
        ),
      ),
      child: child,
    );
  }
} 