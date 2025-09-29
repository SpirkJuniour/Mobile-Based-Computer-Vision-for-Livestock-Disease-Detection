import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('History page will be implemented here'),
      ),
    );
  }
}
