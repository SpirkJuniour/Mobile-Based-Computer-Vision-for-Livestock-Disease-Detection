import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class DecoratedBackground extends StatelessWidget {
  const DecoratedBackground({
    super.key,
    required this.child,
    this.showHeroOverlay = true,
    this.padding,
  });

  final Widget child;
  final bool showHeroOverlay;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neutralSurface,
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showHeroOverlay) ...[
            Positioned(
              top: -120,
              left: -40,
              child: _GlowBlob(
                diameter: 320,
                color: AppTheme.primarySoft.withValues(alpha: 0.45),
              ),
            ),
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                diameter: 260,
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
            ),
          ],
          Positioned.fill(
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.diameter,
    required this.color,
  });

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}


