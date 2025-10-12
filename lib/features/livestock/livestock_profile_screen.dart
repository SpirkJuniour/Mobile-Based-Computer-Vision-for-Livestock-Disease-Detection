import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class LivestockProfileScreen extends StatelessWidget {
  final String livestockId;
  
  const LivestockProfileScreen({super.key, required this.livestockId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cow #$livestockId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: AppColors.primaryLight,
              child: const Center(
                child: Icon(Icons.pets, size: 100, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'Tag Number', livestockId),
                  _buildInfoRow(context, 'Breed', 'Friesian'),
                  _buildInfoRow(context, 'Age', '3 years'),
                  _buildInfoRow(context, 'Weight', '400 kg'),
                  _buildInfoRow(context, 'Gender', 'Female'),
                  const SizedBox(height: 24),
                  Text(
                    'Health History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text('No health issues recorded'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

