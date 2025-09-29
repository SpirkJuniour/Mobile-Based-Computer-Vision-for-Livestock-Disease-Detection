import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextPage();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _mainController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      
      if (isFirstTime) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
              AppTheme.accentColor,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top decorative elements
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      // Decorative icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDecorativeIcon(Icons.agriculture, 0.3),
                          _buildDecorativeIcon(Icons.eco, 0.5),
                          _buildDecorativeIcon(Icons.nature, 0.4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Main content
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Icon with pulse animation
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(35),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: AppTheme.tertiaryColor.withOpacity(0.3),
                                            blurRadius: 30,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.pets,
                                        size: 70,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                              
                              // App Name
                              Text(
                                'Mifugo Care',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textOnPrimary,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // App Description
                              Text(
                                'AI-Powered Livestock Health',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textOnPrimary.withOpacity(0.9),
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Disease Detection & Management',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textOnPrimary.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 60),
                              
                              // Loading indicator with custom styling
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.textOnPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.textOnPrimary,
                                  ),
                                  strokeWidth: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom decorative elements
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDecorativeIcon(Icons.health_and_safety, 0.4),
                          _buildDecorativeIcon(Icons.science, 0.3),
                          _buildDecorativeIcon(Icons.analytics, 0.5),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeIcon(IconData icon, double opacity) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.textOnPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: AppTheme.textOnPrimary.withOpacity(opacity),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
