import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_colors.dart';
import '../../core/providers/auth_provider.dart';

/// Home Dashboard Screen
/// Clean white design with modern layout
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${user?.fullName.split(' ')[0] ?? 'User'}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Welcome to Kenya',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Search and Notifications
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        context.pushNamed('search');
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        context.pushNamed('notifications');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Search Section
                Text(
                  'What are you looking for today',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search here',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.tune,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Category Section
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Category Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryButton(
                        context,
                        title: 'Beef Farming',
                        icon: Icons.pets,
                        isSelected: true,
                        onTap: () => context.pushNamed('beef-farming'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryButton(
                        context,
                        title: 'Goat Farming',
                        icon: Icons.pets,
                        isSelected: false,
                        onTap: () => context.pushNamed('goat-farming'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Promotional Banner
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(
                        'images/screenshot2.png',
                      ), // Using your existing image
                      fit: BoxFit.cover,
                      onError: null,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dark overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.darkToTransparent,
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            const Text(
                              '25% Off',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'for this month',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textWhite.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.textWhite,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kenya, East Africa',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.send,
                                    color: AppColors.textWhite,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Action Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.camera_alt,
                      title: 'Diagnose Animal',
                      color: AppColors.primary,
                      onTap: () => context.pushNamed('camera'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.history,
                      title: 'View History',
                      color: AppColors.info,
                      onTap: () => context.pushNamed('diagnosis-history'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.pets,
                      title: 'My Livestock',
                      color: AppColors.success,
                      onTap: () => context.pushNamed('livestock'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.medical_information,
                      title: 'Health Tips',
                      color: AppColors.warning,
                      onTap: () => context.pushNamed('health-tips'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.pushNamed('diagnosis-history');
              break;
            case 2:
              context.pushNamed('livestock');
              break;
            case 3:
              context.pushNamed('settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Livestock'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textWhite
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
