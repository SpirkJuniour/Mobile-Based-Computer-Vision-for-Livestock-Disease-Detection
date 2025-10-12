import 'package:flutter/material.dart';

class GoatFarmingScreen extends StatelessWidget {
  const GoatFarmingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goat Farming')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goat Farming Guide', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            const Text('Comprehensive information about goat farming, breeds, nutrition, and management practices.'),
          ],
        ),
      ),
    );
  }
}

