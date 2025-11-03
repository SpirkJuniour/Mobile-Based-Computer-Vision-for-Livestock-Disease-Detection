import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';

/// Modern Onboarding Screen for Livestock Disease Detection
/// Features hero image, information tags, and call-to-action button
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo at Top
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: _buildHoofLogo(size: 120),
                  ),
                ),

                const SizedBox(height: 32),

                // Top Bar with Language Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Language Toggle
                      InkWell(
                        onTap: () {
                          setState(() {
                            isEnglish = !isEnglish;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            isEnglish ? 'EN | SW' : 'SW | EN',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Information Tags
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(
                        icon: Icons.medical_services,
                        text: '5 Diseases',
                      ),
                      _buildInfoChip(
                        icon: Icons.speed,
                        text: '>95% Accuracy',
                      ),
                      _buildInfoChip(
                        icon: Icons.check_circle,
                        text: 'Instant',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Main Content
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        isEnglish ? 'MifugoCare' : 'MifugoCare',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        isEnglish
                            ? 'Detect livestock diseases instantly using AI computer vision. Get treatment recommendations and keep your animals healthy.'
                            : 'Gundua magonjwa ya mifugo haraka kwa kutumia teknolojia ya AI. Pata mapendekezo ya matibabu na weka wanyama wako wenye afya.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed('role-selection');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                isEnglish
                                    ? 'Start Diagnosis'
                                    : 'Anza Uchunguzi',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Custom Hoof Logo Widget
  Widget _buildHoofLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _HoofPainter(),
      ),
    );
  }
}

// Custom Painter for Hoof Icon
class _HoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double scale = size.width / 120;

    // Main hoof body (rounded U-shape)
    final path = Path();
    path.moveTo(centerX - 25 * scale, centerY - 10 * scale);
    path.quadraticBezierTo(
      centerX - 30 * scale,
      centerY + 20 * scale,
      centerX - 20 * scale,
      centerY + 30 * scale,
    );
    path.lineTo(centerX + 20 * scale, centerY + 30 * scale);
    path.quadraticBezierTo(
      centerX + 30 * scale,
      centerY + 20 * scale,
      centerX + 25 * scale,
      centerY - 10 * scale,
    );
    path.quadraticBezierTo(
      centerX,
      centerY - 15 * scale,
      centerX - 25 * scale,
      centerY - 10 * scale,
    );
    canvas.drawPath(path, paint);

    // Hoof toes (two cloven parts)
    // Left toe
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 12 * scale, centerY - 20 * scale),
        width: 16 * scale,
        height: 24 * scale,
      ),
      paint,
    );

    // Right toe
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 12 * scale, centerY - 20 * scale),
        width: 16 * scale,
        height: 24 * scale,
      ),
      paint,
    );

    // Dewclaws (small back toes)
    // Left dewclaw
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 28 * scale, centerY - 5 * scale),
        width: 8 * scale,
        height: 12 * scale,
      ),
      paint,
    );

    // Right dewclaw
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 28 * scale, centerY - 5 * scale),
        width: 8 * scale,
        height: 12 * scale,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
