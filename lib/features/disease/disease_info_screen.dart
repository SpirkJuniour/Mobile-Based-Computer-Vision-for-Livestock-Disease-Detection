import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class DiseaseInfoScreen extends StatelessWidget {
  final String diseaseName;
  
  const DiseaseInfoScreen({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diseaseName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Description',
              'Detailed information about $diseaseName will be displayed here.',
            ),
            _buildSection(
              context,
              'Symptoms',
              '• Symptom 1\n• Symptom 2\n• Symptom 3',
            ),
            _buildSection(
              context,
              'Treatment',
              '• Treatment option 1\n• Treatment option 2\n• Treatment option 3',
            ),
            _buildSection(
              context,
              'Prevention',
              '• Prevention measure 1\n• Prevention measure 2\n• Prevention measure 3',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

