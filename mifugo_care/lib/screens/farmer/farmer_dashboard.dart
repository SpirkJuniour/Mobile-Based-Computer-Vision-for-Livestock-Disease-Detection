import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mifugo_care/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../models/diagnosis_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/decorated_background.dart';
import '../../widgets/common/glow_card.dart';
import '../../widgets/common/brand_wordmark.dart';
import '../../widgets/navigation/pill_navigation_bar.dart';
import '../common/profile_menu_tile.dart';
import '../common/settings_screen.dart';
import 'diagnosis_history_screen.dart';
import 'livestock_list_screen.dart';
import 'upload_image_screen.dart';
import 'vet_consult_screen.dart';
import 'insights_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _currentIndex = 0;
  final DatabaseService _firestoreService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: DecoratedBackground(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 110),
          child: IndexedStack(
        index: _currentIndex,
        children: [
              _buildHomeTab(user?.uid ?? '', user?.displayName ?? 'Farmer'),
          const LivestockListScreen(),
          const DiagnosisHistoryScreen(),
          _buildProfileTab(),
        ],
      ),
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return PillNavigationBar(
            items: [
              PillNavigationItem(icon: Icons.home_rounded, label: localizations.home),
              PillNavigationItem(icon: Icons.pets_rounded, label: localizations.livestock),
              PillNavigationItem(icon: Icons.history_rounded, label: localizations.history),
              PillNavigationItem(icon: Icons.person_rounded, label: localizations.profile),
            ],
            currentIndex: _currentIndex,
            onChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadImageScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: Builder(
                builder: (context) {
                  final localizations = AppLocalizations.of(context)!;
                  return Text(localizations.scanLivestock);
                },
              ),
            )
          : null,
    );
  }

  Widget _buildHomeTab(String farmerId, String displayName) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 12, left: 16, right: 16),
            child: BrandWordmark(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                _DashboardHero(name: displayName),
                const SizedBox(height: 24),
                _MetricsRow(farmerId: farmerId),
                const SizedBox(height: 24),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
          const SizedBox(height: 16),
                _QuickActions(
                  onScanTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadImageScreen(),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 32),
          Text(
                  'Recent diagnoses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 32),
          sliver: SliverToBoxAdapter(
            child: StreamBuilder<List<DiagnosisModel>>(
            stream: _firestoreService.streamDiagnosesByFarmer(farmerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final diagnoses = snapshot.data ?? [];
              if (diagnoses.isEmpty) {
                  return GlowCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 54,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                        const SizedBox(height: 16),
                        Text(
                          'No diagnoses yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a livestock photo to generate AI-assisted diagnoses.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                  ),
                );
              }

                return Column(
                  children: diagnoses.take(5).map((diagnosis) {
                    final confidence =
                        ((diagnosis.confidenceScore ?? 0) * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlowCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
              children: [
                Container(
                              height: 54,
                              width: 54,
                  decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                                Icons.medical_services_outlined,
                    color: AppTheme.primaryColor,
                                size: 28,
                  ),
                ),
                            const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                                    diagnosis.diseaseLabel ?? 'Unknown',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontSize: 17),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Confidence $confidence%',
                                    style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                                    'Status • ${diagnosis.status}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                            _StatusPill(status: diagnosis.status),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 32, bottom: 80),
      child: Column(
        children: [
          GlowCard(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: Column(
              children: [
                Container(
                  height: 82,
                  width: 82,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
            child: const Icon(
              Icons.person,
                    size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
                const SizedBox(height: 18),
          Text(
                  user?.displayName ?? 'Farmer',
                  style: Theme.of(context).textTheme.titleLarge,
          ),
                const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              return GlowCard(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.edit_outlined,
                      title: localizations.editProfile,
                      subtitle: localizations.updateYourInfo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuTile(
                      icon: Icons.notifications_outlined,
                      title: localizations.notifications,
                      subtitle: localizations.configureAlerts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      title: localizations.settings,
                      subtitle: localizations.customizePreferences,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ProfileMenuTile(
                      icon: Icons.logout,
                      iconColor: AppTheme.errorColor,
                      title: localizations.signOut,
                      subtitle: localizations.logOutOfMifugoCare,
                      titleStyle: const TextStyle(color: AppTheme.errorColor),
                      onTap: () async {
                        await authProvider.signOut();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track health insights, view diagnoses and connect with vets.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _HeroTag(label: 'Disease detection'),
                    _HeroTag(label: 'Vet network'),
                    _HeroTag(label: '3+ insights/week'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primarySoft.withValues(alpha: 0.8),
                  AppTheme.primaryColor.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_graph_outlined,
              size: 38,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          GlowCard(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick disease scan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload livestock photos to diagnose issues instantly.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onScanTap,
                    child: const Text('Start scan'),
                  ),
                ],
              ),
            ),
          ),
          GlowCard(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Consult a vet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share cases and receive expert responses.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VetConsultScreen(),
                        ),
                      );
                    },
                    child: const Text('Open inbox'),
                  ),
                ],
              ),
            ),
          ),
          GlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.insights_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wellness insights',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep track of herd health with smart summaries.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InsightsScreen(),
                        ),
                      );
                    },
                    child: const Text('View insights'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.pets_outlined,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'My livestock',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep an eye on herd records and vaccination schedules.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.history_toggle_off,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Case history',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Review earlier diagnoses and vet recommendations.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppTheme.warningColor;
        break;
      case 'reviewed':
      case 'treated':
        color = AppTheme.successColor;
        break;
      default:
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

