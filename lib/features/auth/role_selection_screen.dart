import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';
import '../../core/models/user_model.dart';

/// Role Selection Screen with clean white design
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo - Hoof Icon
              Center(
                child: _buildHoofLogo(size: 80),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Who are you?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Select your role to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 32),

              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      role: UserRole.farmer,
                      icon: Icons.agriculture,
                      title: 'Farmer',
                      description: 'Manage livestock and diagnose diseases',
                      isSelected: selectedRole == UserRole.farmer,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.farmer;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      role: UserRole.veterinarian,
                      icon: Icons.medical_services,
                      title: 'Veterinarian',
                      description: 'Professional diagnosis and treatment',
                      isSelected: selectedRole == UserRole.veterinarian,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.veterinarian;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRole != null
                      ? () {
                          context.pushNamed(
                            'signup',
                            queryParameters: {'role': selectedRole!.name},
                          );
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 16),

              // Already have account or Admin
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.pushNamed('login');
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        _showAdminLogin(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text(
                        'Admin Access',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.textWhite : AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textWhite,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Admin login dialog
  void _showAdminLogin(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Administrator Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Admin Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Check hardcoded admin credentials
              if (emailController.text == 'admin@mifugocare.com' &&
                  passwordController.text == 'Admin2024!') {
                Navigator.pop(context);
                context.pushReplacementNamed('home-dashboard');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Welcome, Administrator!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin credentials'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Login'),
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

    // Main hoof body
    final path = Path();
    path.moveTo(centerX - 25 * scale, centerY - 10 * scale);
    path.quadraticBezierTo(
      centerX - 30 * scale, centerY + 20 * scale,
      centerX - 20 * scale, centerY + 30 * scale,
    );
    path.lineTo(centerX + 20 * scale, centerY + 30 * scale);
    path.quadraticBezierTo(
      centerX + 30 * scale, centerY + 20 * scale,
      centerX + 25 * scale, centerY - 10 * scale,
    );
    path.quadraticBezierTo(
      centerX, centerY - 15 * scale,
      centerX - 25 * scale, centerY - 10 * scale,
    );
    canvas.drawPath(path, paint);

    // Hoof toes
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 12 * scale, centerY - 20 * scale),
        width: 16 * scale,
        height: 24 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 12 * scale, centerY - 20 * scale),
        width: 16 * scale,
        height: 24 * scale,
      ),
      paint,
    );

    // Dewclaws
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 28 * scale, centerY - 5 * scale),
        width: 8 * scale,
        height: 12 * scale,
      ),
      paint,
    );
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
