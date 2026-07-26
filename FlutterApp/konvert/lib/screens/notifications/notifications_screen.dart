import 'package:flutter/material.dart';
import '../../managers/theme_manager.dart';
import '../../services/storage_service.dart';
import '../../models/notification.dart';
import 'notification_details_screen.dart';
import '../../utils/page_transitions.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFilters = {};
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = StorageService.instance.getNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppNotification> get _filteredNotifications {
    return _notifications.where((n) {
      // Apply Search
      final matchesSearch =
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.body.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      // Apply Unread Filter
      if (_selectedFilters.contains('Unread') && n.isRead) {
        return false;
      }

      // Apply Type Filters (Important, Requests)
      final hasImportant = _selectedFilters.contains('Important');
      final hasRequests = _selectedFilters.contains('Requests');

      if (hasImportant || hasRequests) {
        bool matchesType = false;
        if (hasImportant && n.type == NotificationType.important) {
          matchesType = true;
        }
        if (hasRequests && n.type == NotificationType.request) {
          matchesType = true;
        }
        if (!matchesType) return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<AppNotification>> _groupNotifications(
    List<AppNotification> list,
  ) {
    final Map<String, List<AppNotification>> grouped = {};
    for (var n in list) {
      final dateStr = _formatDateHeader(n.timestamp);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(n);
    }
    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Today';
    if (targetDate == yesterday) return 'Yesterday';

    final suffix = _getDayOfMonthSuffix(date.day);
    return '${date.day}$suffix ${DateFormat('MMMM, yyyy').format(date)}';
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

  void _openDetails(AppNotification notification) async {
    // Mark as read
    if (!notification.isRead) {
      await StorageService.instance.markNotificationAsRead(notification.id);
      _loadNotifications(); // Refresh list
    }

    if (mounted) {
      // Find the updated notification
      final updatedN = StorageService.instance.getNotifications().firstWhere(
        (n) => n.id == notification.id,
      );
      Navigator.push(
        context,
        PageTransitions.fadeTransition(
          NotificationDetailsScreen(notification: updatedN),
        ),
      ).then((_) {
        // Refresh when coming back just in case
        _loadNotifications();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedNotifications = _groupNotifications(_filteredNotifications);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020414)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: isDark
                    ? const Color(0xFF020414)
                    : const Color(0xFFF8FAFC),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ThemeManager.instance.getMatchColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0022FF),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF111526)
                          : const Color(0xFFF6F8FD),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A324A)
                            : const Color(0xFFD4DDF3),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? const Color(0xFF829AB1)
                              : const Color(0xFF64748B),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: TextStyle(
                              color: ThemeManager.instance.getMatchColor(),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search notifications',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? const Color(0xFF829AB1)
                                  : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Filters (All, Unread, Important, Requests)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('Unread', isDark),
                      _buildFilterChip('Important', isDark),
                      _buildFilterChip('Requests', isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Notifications List Grouped by Date
                Expanded(
                  child: groupedNotifications.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications found',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groupedNotifications.keys.length,
                          itemBuilder: (context, index) {
                            final dateKey = groupedNotifications.keys.elementAt(
                              index,
                            );
                            final items = groupedNotifications[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                    top: 12,
                                  ),
                                  child: Text(
                                    dateKey,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF7A7EA1),
                                    ),
                                  ),
                                ),
                                ...items
                                    .map(
                                      (n) => _buildNotificationItem(n, isDark),
                                    )
                                    .toList(),
                              ],
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
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isActive = _selectedFilters.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedFilters.add(label);
            } else {
              _selectedFilters.remove(label);
            }
          });
        },
        backgroundColor: isDark
            ? const Color(0xFF111526)
            : const Color(0xFFF6F8FD),
        selectedColor: isDark
            ? const Color.fromARGB(80, 41, 51, 73)
            : const Color(0xFFD4DDF3),
        labelStyle: TextStyle(
          color: isActive
              ? (isDark ? Colors.white : const Color(0xFF0022FF))
              : (isDark ? const Color(0xFF829AB1) : const Color(0xFF64748B)),
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive
                ? (isDark ? const Color(0xFF829AB1) : const Color(0xFF64748B))
                : (isDark ? const Color(0xFF2A324A) : const Color(0xFFD4DDF3)),
            width: 0,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification, bool isDark) {
    final String iconPath;
    final Color bgColor;
    final Color iconBgColor;

    if (notification.type == NotificationType.request) {
      iconPath = isDark
          ? 'assets/extras/notificationRequestDark.png'
          : 'assets/extras/notificationRequestLight.png';
      iconBgColor = const Color(0xFFFEF3C7);
    } else if (notification.type == NotificationType.important) {
      iconPath = isDark
          ? 'assets/extras/notificationImportantDark.png'
          : 'assets/extras/notificationImportantLight.png';
      iconBgColor = const Color(0xFFFEE2E2);
    } else {
      iconPath = isDark
          ? 'assets/extras/notificationNormalDark.png'
          : 'assets/extras/notificationNormalLight.png';
      iconBgColor = const Color(0xFFE0E7FF);
    }

    if (notification.isRead) {
      bgColor = isDark
          ? const Color.fromARGB(80, 41, 51, 73)
          : const Color(0xFFF3F4F9);
    } else {
      bgColor = isDark ? const Color.fromARGB(150, 41, 51, 73) : Colors.white;
    }

    return GestureDetector(
      onTap: () => _openDetails(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: notification.isRead || isDark
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 36,
              decoration: BoxDecoration(
                color: notification.isRead && !isDark
                    ? Colors.transparent
                    : (isDark ? Colors.transparent : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(iconPath, width: 16, height: 16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? (notification.isRead
                                ? Colors.white70
                                : Colors.white)
                          : (notification.isRead
                                ? Colors.black87
                                : Colors.black),
                    ),
                  ),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
