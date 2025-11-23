import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/diagnosis_model.dart';
import '../../models/vet_case_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/brand_wordmark.dart';

class CaseDetailScreen extends StatefulWidget {
  final DiagnosisModel diagnosis;

  const CaseDetailScreen({super.key, required this.diagnosis});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final _notesController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _firestoreService = DatabaseService();
  final _notificationService = NotificationService();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  Future<void> _acceptCase() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add notes before accepting the case'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final vetId = authProvider.currentUser?.uid ?? '';

      // Update diagnosis status
      await _firestoreService.updateDiagnosis(widget.diagnosis.id, {
        'status': 'reviewed',
        'reviewedAt': DateTime.now(),
        'reviewedBy': vetId,
      });

      // Create vet case
      final vetCase = {
        'diagnosisId': widget.diagnosis.id,
        'farmerId': widget.diagnosis.farmerId,
        'vetId': vetId,
        'notes': _notesController.text.trim(),
        'treatmentPlan': _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        'status': 'in_progress',
        'createdAt': DateTime.now(),
      };

      await _firestoreService.addVetCase(
        VetCaseModel.fromMap(vetCase, ''),
      );

      // Send notification to farmer
      await _notificationService.notifyVetResponse(
        farmerId: widget.diagnosis.farmerId,
        caseId: widget.diagnosis.id,
        vetName: authProvider.currentUser?.displayName ?? 'Veterinarian',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case accepted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept case: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.diagnosis.imageUrl != null)
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.diagnosis.imageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: AppTheme.cardColor,
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Diagnosis',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Disease',
                      widget.diagnosis.diseaseLabel ?? 'Unknown',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Confidence',
                      '${((widget.diagnosis.confidenceScore ?? 0) * 100).toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Date',
                      _formatDate(widget.diagnosis.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.diagnosis.recommendedAction != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Action',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.diagnosis.recommendedAction!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veterinary Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter your professional assessment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Treatment Plan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _treatmentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter treatment recommendations...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _acceptCase,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Accept Case'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

