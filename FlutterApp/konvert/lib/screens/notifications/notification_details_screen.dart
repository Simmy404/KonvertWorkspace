import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../managers/theme_manager.dart';
import 'package:intl/intl.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  String _formatDateTime(DateTime date) {
    final suffix = _getDayOfMonthSuffix(date.day);
    return '${date.day}$suffix ${DateFormat('MMMM, yyyy').format(date)} at ${DateFormat('h:mm a').format(date).toLowerCase()}';
  }

  String _getDayOfMonthSuffix(int dayNum) {
    if (dayNum >= 11 && dayNum <= 13) return 'th';
    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String iconPath;
    final Color cardColor = isDark
        ? const Color(0xFF1E2436)
        : const Color(0xFFF8FAFC);

    if (notification.type == NotificationType.request) {
      iconPath = isDark
          ? 'assets/extras/notificationRequestDark.png'
          : 'assets/extras/notificationRequestLight.png';
    } else if (notification.type == NotificationType.important) {
      iconPath = isDark
          ? 'assets/extras/notificationImportantDark.png'
          : 'assets/extras/notificationImportantLight.png';
    } else {
      iconPath = isDark
          ? 'assets/extras/notificationNormalDark.png'
          : 'assets/extras/notificationNormalLight.png';
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020414) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: isDark ? const Color(0xFF020414) : const Color(0xFFF8FAFC),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1E56E2),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E56E2),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2B3245)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(iconPath, width: 24, height: 24),
                          const SizedBox(height: 16),
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDateTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'regards,\nKonvert',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contact Support Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // Contact support action
                      },
                      child: Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
