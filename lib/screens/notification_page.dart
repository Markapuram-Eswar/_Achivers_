import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // This would typically come from a backend or state management
  // For now, we'll use an empty list to simulate no notifications
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch notifications from backend (API call, database read) */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _notifications.isEmpty
          ? _buildEmptyNotifications()
          : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No new notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
            title: Text(notification['title']),
            subtitle: Text(notification['message']),
            trailing: Text(
              notification['time'],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
