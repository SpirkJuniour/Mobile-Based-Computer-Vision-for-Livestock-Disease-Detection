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
              // Logo
              Center(
                child: Image.asset(
                  'images/mifugocarelogo.png', // Using your existing logo
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.pets, size: 40, color: AppColors.primary),
                    );
                  },
                ),
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
                    
                    const SizedBox(height: 16),
                    
                    _buildRoleCard(
                      role: UserRole.administrator,
                      icon: Icons.admin_panel_settings,
                      title: 'Administrator',
                      description: 'System administration and management',
                      isSelected: selectedRole == UserRole.administrator,
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.administrator;
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
              
              // Already have account
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushNamed('login');
                  },
                  child: const Text('Already have an account? Login'),
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
                  color: isSelected 
                      ? AppColors.primary 
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? AppColors.textWhite 
                      : AppColors.primary,
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
}
