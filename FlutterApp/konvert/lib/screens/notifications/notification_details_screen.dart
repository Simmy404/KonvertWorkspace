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
    final String iconPath;
    final Color cardColor = ThemeManager.instance.getContainerColor();

    if (notification.type == NotificationType.request) {
      iconPath = ThemeManager.instance.isLightMode
          ? 'assets/extras/notificationRequestLight.png'
          : 'assets/extras/notificationRequestDark.png';
    } else if (notification.type == NotificationType.important) {
      iconPath = ThemeManager.instance.isLightMode
          ? 'assets/extras/notificationImportantLight.png'
          : 'assets/extras/notificationImportantDark.png';
    } else {
      iconPath = ThemeManager.instance.isLightMode
          ? 'assets/extras/notificationNormalLight.png'
          : 'assets/extras/notificationNormalDark.png';
    }

    return Scaffold(
      backgroundColor: ThemeManager.instance.getAppBackgroundColor(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: ThemeManager.instance.getAppBackgroundColor(),
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
                          color: ThemeManager.instance.getBorderColor(),
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
                              color: ThemeManager.instance.getTextPrimary(),
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
                              color: ThemeManager.instance.getTextTertiary(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...notification.body.map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeManager.instance.getTextSecondary(),
                                height: 1.5,
                              ),
                            ),
                          )),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'regards,\nKonvert',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: ThemeManager.instance.getTextSecondary(),
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
                          color: ThemeManager.instance.getTextPrimary(),
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
