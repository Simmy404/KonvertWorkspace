import 'package:flutter/material.dart';
import '../managers/activity_manager.dart';
import '../managers/theme_manager.dart';
import '../models/user_activity.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        final theme = ThemeManager.instance;
        final isLight = theme.isLightMode;
        final titleColor = isLight ? const Color(0xFF0022FF) : Colors.white;

        return Scaffold(
          backgroundColor: theme.getContrastColor(),
          body: Stack(
            children: [
              // Dynamic Background Image Layer (mainBG)
              Positioned.fill(
                child: Image.asset(
                  theme.getMainBG(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Colors.black),
                ),
              ),

              // Foreground Content
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: titleColor,
                                size: 24,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'My Activity',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          ListenableBuilder(
                            listenable: ActivityManager.instance,
                            builder: (context, _) {
                              if (ActivityManager.instance.activities.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return TextButton.icon(
                                onPressed: () => _confirmClearHistory(context),
                                icon: const Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                label: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Activity List View
                    Expanded(
                      child: ListenableBuilder(
                        listenable: ActivityManager.instance,
                        builder: (context, _) {
                          final activities = ActivityManager.instance.activities;

                          if (activities.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: theme.getAccentBlue().withOpacity(isLight ? 0.08 : 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history_toggle_off_rounded,
                                      size: 48,
                                      color: theme.getAccentBlue(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No past activity logged',
                                    style: TextStyle(
                                      color: theme.getTextPrimary(),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Actions like placing bookings\nwill appear here automatically.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.getTextSecondary(),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return _buildActivityTile(activity, theme);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTile(UserActivity activity, ThemeManager theme) {
    final isLight = theme.isLightMode;
    final cardBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
    final cardBorder = isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A);

    // Dynamic Icon & Accent Color per activity type
    IconData icon;
    Color iconColor;

    switch (activity.type) {
      case 'booking_created':
        icon = Icons.shopping_bag_rounded;
        iconColor = isLight ? const Color(0xFF2563EB) : const Color(0xFF60A5FA);
        break;
      case 'booking_edited':
        icon = Icons.edit_rounded;
        iconColor = const Color(0xFFF59E0B); // Amber
        break;
      case 'booking_deleted':
        icon = Icons.delete_outline_rounded;
        iconColor = const Color(0xFFEF4444); // Red
        break;
      case 'booking_uploaded':
        icon = Icons.cloud_upload_rounded;
        iconColor = const Color(0xFF10B981); // Emerald Green
        break;
      default:
        icon = Icons.local_activity_rounded;
        iconColor = theme.getAccentBlue();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Solid Icon Circle Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isLight ? 0.12 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Activity Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activity.timeAgo,
                        style: TextStyle(
                          color: theme.getTextSecondary().withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (activity.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ThemeManager.instance.getContainerColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear Activity History',
          style: TextStyle(
            color: ThemeManager.instance.getTextPrimary(),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all logged activities?',
          style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
            ),
          ),
          TextButton(
            onPressed: () {
              ActivityManager.instance.clearActivities();
              Navigator.pop(dialogCtx);
            },
            child: const Text(
              'Clear History',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
