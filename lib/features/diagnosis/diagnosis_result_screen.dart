import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';
import '../../core/models/diagnosis_model.dart';
import '../../core/services/database_service.dart';

/// Diagnosis Result Screen
/// Displays disease detection results with detailed information
class DiagnosisResultScreen extends StatefulWidget {
  final Map<String, dynamic> diagnosisData;

  const DiagnosisResultScreen({
    super.key,
    required this.diagnosisData,
  });

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  late DiagnosisModel diagnosis;
  File? imageFile;
  Map<String, dynamic>? imageAnalysis;
  String? confidenceLevel;
  String? urgencyLevel;

  @override
  void initState() {
    super.initState();
    diagnosis = widget.diagnosisData['diagnosis'] as DiagnosisModel;
    imageFile = widget.diagnosisData['image'] as File?;

    // Extract additional ML analysis data
    if (diagnosis.rawData != null) {
      imageAnalysis = diagnosis.rawData!['imageAnalysis'];
      confidenceLevel = _getConfidenceLevel(diagnosis.confidence);
      urgencyLevel =
          _getUrgencyLevel(diagnosis.diseaseName, diagnosis.confidence);
    }

    // Save diagnosis to database
    DatabaseService.instance.insertDiagnosis(diagnosis);
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = AppColors.getConfidenceColor(diagnosis.confidence);
    final severityColor = AppColors.getSeverityColor(diagnosis.severityLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageFile != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name
                  Text(
                    diagnosis.diseaseName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: diagnosis.isHealthy
                              ? AppColors.success
                              : AppColors.error,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Confidence & Severity Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.analytics,
                          label: 'Confidence',
                          value: '${diagnosis.confidence.toStringAsFixed(1)}%',
                          subtitle: confidenceLevel ?? 'Unknown',
                          color: confidenceColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.warning_amber,
                          label: 'Severity',
                          value: diagnosis.severityDescription,
                          subtitle: urgencyLevel ?? 'Unknown',
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),

                  // Image Analysis (if available)
                  if (imageAnalysis != null) ...[
                    const SizedBox(height: 24),
                    _buildImageAnalysisCard(context),
                  ],

                  const SizedBox(height: 32),

                  // Symptoms
                  if (diagnosis.symptoms.isNotEmpty) ...[
                    Text(
                      'Symptoms',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ...diagnosis.symptoms.map((symptom) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.fiber_manual_record,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  symptom,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Recommended Treatments
                  if (diagnosis.recommendedTreatments.isNotEmpty) ...[
                    Text(
                      'Recommended Treatments',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ...diagnosis.recommendedTreatments
                        .map((treatment) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 20, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      treatment,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    const SizedBox(height: 24),
                  ],

                  // Prevention Steps
                  if (diagnosis.preventionSteps.isNotEmpty) ...[
                    Text(
                      'Prevention & Care',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ...diagnosis.preventionSteps.map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield,
                                  size: 20, color: AppColors.info),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.pushNamed('disease-info', pathParameters: {
                              'name': diagnosis.diseaseName,
                            });
                          },
                          icon: const Icon(Icons.info),
                          label: const Text('Learn More'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.goNamed('home');
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Go Home'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageAnalysisCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Image Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisItem(
                    context,
                    'Brightness',
                    '${imageAnalysis!['brightness']?.toStringAsFixed(1) ?? 'N/A'}',
                    Icons.brightness_6,
                  ),
                ),
                Expanded(
                  child: _buildAnalysisItem(
                    context,
                    'Contrast',
                    '${imageAnalysis!['contrast']?.toStringAsFixed(1) ?? 'N/A'}',
                    Icons.contrast,
                  ),
                ),
                Expanded(
                  child: _buildAnalysisItem(
                    context,
                    'Lesions',
                    imageAnalysis!['hasSkinLesions'] == true
                        ? 'Detected'
                        : 'None',
                    Icons.medical_services,
                    color: imageAnalysis!['hasSkinLesions'] == true
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Get confidence level description
  String _getConfidenceLevel(double confidence) {
    if (confidence > 80) return 'High';
    if (confidence > 60) return 'Medium';
    return 'Low';
  }

  /// Get urgency level description
  String _getUrgencyLevel(String disease, double confidence) {
    final urgentDiseases = [
      'Lumpy Skin Disease',
      'Foot and Mouth Disease',
      'Mastitis'
    ];
    if (urgentDiseases.contains(disease) && confidence > 70) return 'High';
    if (urgentDiseases.contains(disease) && confidence > 50) return 'Medium';
    return 'Low';
  }
}
