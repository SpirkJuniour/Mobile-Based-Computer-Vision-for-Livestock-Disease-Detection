import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/diagnosis_model.dart';
import '../../services/database_service.dart';
import '../../widgets/common/glow_card.dart';
import '../../widgets/common/brand_wordmark.dart';
import 'case_detail_screen.dart';

class PendingCasesScreen extends StatelessWidget {
  const PendingCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = DatabaseService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: BrandWordmark(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<DiagnosisModel>>(
      stream: firestoreService.streamPendingDiagnoses(),
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'No pending cases',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'All farmer submissions are up to date.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: diagnoses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final diagnosis = diagnoses[index];
            final confidence =
                ((diagnosis.confidenceScore ?? 0) * 100).toStringAsFixed(0);
            return GlowCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.diseaseLabel ?? 'Unknown disease',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Confidence $confidence%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(diagnosis.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaseDetailScreen(diagnosis: diagnosis),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

