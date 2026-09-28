import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final notifications = appState.notifications;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications at this time.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final notif = notifications[index];
                final isWarning = notif.type == 'warning' || notif.type == 'action_required';
                final isSuccess = notif.type == 'success';

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: notif.isRead ? 0.65 : 1.0,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isWarning
                                  ? AppTheme.statusWarningBg
                                  : (isSuccess ? AppTheme.statusSuccessBg : AppTheme.statusInfoBg),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWarning
                                  ? Icons.warning_amber_rounded
                                  : (isSuccess ? Icons.check_circle_outline : Icons.notifications_outlined),
                              size: 18,
                              color: isWarning
                                  ? AppTheme.statusWarningText
                                  : (isSuccess ? AppTheme.statusSuccessText : AppTheme.statusInfoText),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      notif.date,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.35),
                                ),
                                const SizedBox(height: 6),
                                if (!notif.isRead)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => appState.markNotificationRead(notif.id),
                                      child: const Text(
                                        'Mark as read',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
