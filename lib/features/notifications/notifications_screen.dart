import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            backgroundColor: index % 2 == 0 ? AppColors.primary : AppColors.info,
            child: Icon(
              index % 2 == 0 ? Icons.info : Icons.notifications,
              color: AppColors.textWhite,
            ),
          ),
          title: Text('Notification #${index + 1}'),
          subtitle: const Text('Notification message details...'),
          trailing: const Text('2h ago'),
          onTap: () {},
        ),
      ),
    );
  }
}

