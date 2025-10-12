import 'package:flutter/material.dart';

class BeefFarmingScreen extends StatelessWidget {
  const BeefFarmingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beef Farming')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Beef Farming Guide', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            const Text('Comprehensive information about beef cattle farming, breeds, nutrition, and management practices.'),
          ],
        ),
      ),
    );
  }
}

