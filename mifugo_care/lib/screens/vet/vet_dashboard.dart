import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/decorated_background.dart';
import '../../widgets/common/glow_card.dart';
import '../../widgets/navigation/pill_navigation_bar.dart';
import '../common/profile_menu_tile.dart';
import 'cases_list_screen.dart';
import 'pending_cases_screen.dart';
import '../../widgets/common/brand_wordmark.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key});

  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  int _currentIndex = 0;

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
              _PendingCasesTab(displayName: user?.displayName ?? 'Doctor'),
              _CasesTab(),
              _VetProfileTab(email: user?.email ?? '', name: user?.displayName ?? 'Doctor'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PillNavigationBar(
        items: const [
          PillNavigationItem(icon: Icons.inbox_outlined, label: 'Pending'),
          PillNavigationItem(icon: Icons.folder_open_outlined, label: 'My Cases'),
          PillNavigationItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        currentIndex: _currentIndex,
        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PendingCasesTab extends StatelessWidget {
  const _PendingCasesTab({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(alignment: Alignment.centerLeft, child: BrandWordmark()),
        ),
        const SizedBox(height: 32),
        _VetHero(displayName: displayName),
        const SizedBox(height: 24),
        Expanded(
          child: PendingCasesScreen(),
        ),
      ],
    );
  }
}

class _CasesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const _SectionTitle(
          title: 'Case archive',
          subtitle: 'All cases assigned to you in one place.',
        ),
        const SizedBox(height: 16),
        const Expanded(
          child: CasesListScreen(),
        ),
      ],
    );
  }
}

class _VetHero extends StatelessWidget {
  const _VetHero({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Dr. $displayName',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review farmer submissions, share insights and manage treatment plans.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _HeroBadge(icon: Icons.pending_actions_outlined, label: 'Pending 24h'),
                    _HeroBadge(icon: Icons.stacked_bar_chart, label: 'Insights feed'),
                    _HeroBadge(icon: Icons.shield_outlined, label: 'Secure records'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primarySoft.withValues(alpha: 0.85),
                  AppTheme.primaryDeep.withValues(alpha: 0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _VetProfileTab extends StatelessWidget {
  const _VetProfileTab({required this.email, required this.name});

  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
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
                    Icons.person_outline,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlowCard(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileMenuTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Certifications',
                  subtitle: 'Update specialization and licenses',
                  onTap: () {
                    // TODO: Navigate to certifications
                  },
                ),
                const Divider(height: 1),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Configure alerts and response reminders',
                  onTap: () {
                    // TODO: Navigate to notifications
                  },
                ),
                const Divider(height: 1),
                ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Manage availability and profile visibility',
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                const Divider(height: 1),
                ProfileMenuTile(
                  icon: Icons.logout,
                  iconColor: AppTheme.errorColor,
                  title: 'Sign out',
                  subtitle: 'Log out of Mifugo Care',
                  titleStyle: const TextStyle(color: AppTheme.errorColor),
                  onTap: () async {
                    await authProvider.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


