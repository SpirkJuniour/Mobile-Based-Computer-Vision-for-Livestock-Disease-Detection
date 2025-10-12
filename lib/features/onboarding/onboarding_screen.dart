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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hero Background Image
          Image.asset(
            'images/screenshot.png', // Using your existing image
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 100,
                    color: AppColors.textWhite,
                  ),
                ),
              );
            },
          ),

          // Dark Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkToTransparent,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Language Toggle
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                            color: AppColors.overlayDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isEnglish ? 'EN | SW' : 'SW | EN',
                            style: const TextStyle(
                              color: AppColors.textWhite,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTag(
                        icon: Icons.medical_services,
                        text: '9 Disease Types',
                        top: 60,
                        left: 0,
                      ),
                      _buildInfoTag(
                        icon: Icons.speed,
                        text: '95% Accuracy',
                        top: 120,
                        left: 100,
                      ),
                      _buildInfoTag(
                        icon: Icons.check_circle,
                        text: 'Instant Diagnosis',
                        iconColor: AppColors.success,
                        top: 180,
                        left: 0,
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
                        isEnglish
                            ? 'AI-Powered Livestock Disease Detection'
                            : 'Utambuzi wa Magonjwa ya Mifugo Kwa AI',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        isEnglish
                            ? 'Detect livestock diseases instantly using computer vision. Get treatment recommendations and keep your animals healthy with early diagnosis.'
                            : 'Gundua magonjwa ya mifugo haraka kwa kutumia teknolojia ya AI. Pata mapendekezo ya matibabu na weka wanyama wako wenye afya.',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          height: 1.5,
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
                            backgroundColor: AppColors.backgroundDark,
                            foregroundColor: AppColors.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.textWhite.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16),
                              ),
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
                              const Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildInfoTag({
    required IconData icon,
    required String text,
    required double top,
    required double left,
    Color iconColor = AppColors.textWhite,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.overlayDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
