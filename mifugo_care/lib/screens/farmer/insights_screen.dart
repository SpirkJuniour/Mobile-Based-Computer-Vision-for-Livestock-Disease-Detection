import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/diagnosis_model.dart';
import '../../models/livestock_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/glow_card.dart';
import '../../widgets/common/brand_wordmark.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final farmerId = authProvider.currentUser?.uid ?? '';
    final firestoreService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadInsights(firestoreService, farmerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading insights: ${snapshot.error}'),
            );
          }

          final insights = snapshot.data ?? {};
          final livestockCount = insights['livestockCount'] as int? ?? 0;
          final diagnoses = insights['diagnoses'] as List<DiagnosisModel>? ?? [];
          final livestockList = insights['livestock'] as List<LivestockModel>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Insights',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Track your herd health and disease patterns.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _OverviewMetrics(
                  livestockCount: livestockCount,
                  totalDiagnoses: diagnoses.length,
                  pendingDiagnoses: diagnoses
                      .where((d) => d.status == 'pending')
                      .length,
                ),
                const SizedBox(height: 24),
                if (diagnoses.isNotEmpty) ...[
                  Text(
                    'Disease Trends',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _DiseaseTrends(diagnoses: diagnoses),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Livestock Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _LivestockOverview(livestockList: livestockList),
                if (diagnoses.isEmpty && livestockList.isEmpty) ...[
                  const SizedBox(height: 24),
                  GlowCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          size: 50,
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data available yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add livestock and perform disease scans to see insights here.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadInsights(
      DatabaseService service, String farmerId) async {
    final livestock = await service.getLivestockByFarmer(farmerId);
    final diagnoses = await service.getDiagnosesByFarmer(farmerId);

    return {
      'livestock': livestock,
      'livestockCount': livestock.length,
      'diagnoses': diagnoses,
    };
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({
    required this.livestockCount,
    required this.totalDiagnoses,
    required this.pendingDiagnoses,
  });

  final int livestockCount;
  final int totalDiagnoses;
  final int pendingDiagnoses;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.pets,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '$livestockCount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                Text(
                  'Livestock',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppTheme.successColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalDiagnoses',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                ),
                Text(
                  'Scans',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.pending_actions,
                  color: AppTheme.warningColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '$pendingDiagnoses',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warningColor,
                      ),
                ),
                Text(
                  'Pending',
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

class _DiseaseTrends extends StatelessWidget {
  const _DiseaseTrends({required this.diagnoses});

  final List<DiagnosisModel> diagnoses;

  @override
  Widget build(BuildContext context) {
    // Count diseases
    final diseaseCounts = <String, int>{};
    for (final diagnosis in diagnoses) {
      final disease = diagnosis.diseaseLabel ?? 'Unknown';
      diseaseCounts[disease] = (diseaseCounts[disease] ?? 0) + 1;
    }

    final sortedDiseases = diseaseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedDiseases.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedDiseases.take(5).map((entry) {
          final percentage = (entry.value / diagnoses.length * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      '${entry.value} ($percentage%)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: entry.value / diagnoses.length,
                  backgroundColor: AppTheme.cardColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    entry.key == 'Healthy'
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LivestockOverview extends StatelessWidget {
  const _LivestockOverview({required this.livestockList});

  final List<LivestockModel> livestockList;

  @override
  Widget build(BuildContext context) {
    if (livestockList.isEmpty) {
      return const SizedBox.shrink();
    }

    final typeCounts = <String, int>{};
    for (final livestock in livestockList) {
      typeCounts[livestock.type] = (typeCounts[livestock.type] ?? 0) + 1;
    }

    return GlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...typeCounts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${entry.value}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

