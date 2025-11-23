import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/brand_wordmark.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _diagnosisAlerts = true;
  bool _vetResponses = true;
  bool _healthReminders = true;
  bool _weeklyReports = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _diagnosisAlerts = prefs.getBool('notif_diagnosis_alerts') ?? true;
        _vetResponses = prefs.getBool('notif_vet_responses') ?? true;
        _healthReminders = prefs.getBool('notif_health_reminders') ?? true;
        _weeklyReports = prefs.getBool('notif_weekly_reports') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preference: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure how you receive alerts and updates.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _NotificationSection(
                    title: 'Diagnosis & Health',
                    children: [
                      _NotificationTile(
                        title: 'Disease Detection Alerts',
                        subtitle: 'Get notified when AI detects potential diseases',
                        value: _diagnosisAlerts,
                        onChanged: (value) {
                          setState(() {
                            _diagnosisAlerts = value;
                          });
                          _savePreference('notif_diagnosis_alerts', value);
                        },
                        icon: Icons.medical_services_outlined,
                      ),
                      const Divider(height: 1),
                      _NotificationTile(
                        title: 'Vet Response Alerts',
                        subtitle: 'Notifications when veterinarians respond to your cases',
                        value: _vetResponses,
                        onChanged: (value) {
                          setState(() {
                            _vetResponses = value;
                          });
                          _savePreference('notif_vet_responses', value);
                        },
                        icon: Icons.chat_bubble_outline,
                      ),
                      const Divider(height: 1),
                      _NotificationTile(
                        title: 'Health Reminders',
                        subtitle: 'Reminders for regular livestock health checks',
                        value: _healthReminders,
                        onChanged: (value) {
                          setState(() {
                            _healthReminders = value;
                          });
                          _savePreference('notif_health_reminders', value);
                        },
                        icon: Icons.health_and_safety_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _NotificationSection(
                    title: 'Reports & Insights',
                    children: [
                      _NotificationTile(
                        title: 'Weekly Health Reports',
                        subtitle: 'Receive weekly summaries of your herd health',
                        value: _weeklyReports,
                        onChanged: (value) {
                          setState(() {
                            _weeklyReports = value;
                          });
                          _savePreference('notif_weekly_reports', value);
                        },
                        icon: Icons.insights_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Notification settings are saved automatically. '
                              'Some notifications may still be sent for critical alerts.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

