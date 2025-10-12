import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class VaccinationInfoScreen extends StatelessWidget {
  const VaccinationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Info')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.info,
              child: const Icon(Icons.vaccines, color: AppColors.textWhite),
            ),
            title: Text('Vaccination Schedule #${index + 1}'),
            subtitle: const Text('Details about vaccination...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

