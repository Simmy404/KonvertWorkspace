// lib/screens/profile_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashCount = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final circumference = 2 * pi * radius;
    final dashLength = (circumference / dashCount) * 0.65;
    final spaceLength = (circumference / dashCount) * 0.35;

    double currentAngle = 0.0;
    while (currentAngle < 2 * pi) {
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        false,
        paint,
      );
      currentAngle += (dashLength + spaceLength) / radius;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _onLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = !ThemeManager.instance.isLightMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Log Out',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      await StorageService.instance.logoutUser();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageTransitions.fadeTransition(const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = StorageService.instance.getCurrentUser();
    final String lastSync =
        StorageService.instance.getLastSyncDate() ?? 'Not Synced Yet';

    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        final isLight = ThemeManager.instance.isLightMode;
        final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;
        final subtextColor =
            isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        final cardBg = isLight
            ? Colors.white.withValues(alpha: 0.9)
            : const Color(0xFF1E293B).withValues(alpha: 0.85);
        final borderColor = isLight
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.12);

        return Scaffold(
          backgroundColor: ThemeManager.instance.getContrastColor(),
          body: Stack(
            children: [
              // Dynamic Background Image Layer
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.instance.getMainBG(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Colors.black),
                ),
              ),

              // Content Area
              SafeArea(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'User Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Scrollable Details
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            // Profile Header Card with Dashed Avatar Border
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Dashed PFP Avatar Circle
                                  CustomPaint(
                                    painter: DashedCirclePainter(
                                      color: isLight
                                          ? const Color(0xFF1E56E2)
                                          : const Color(0xFF60A5FA),
                                      strokeWidth: 3.0,
                                      dashCount: 16,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isLight
                                                ? [
                                                    const Color(0xFF2563EB),
                                                    const Color(0xFF1D4ED8),
                                                  ]
                                                : [
                                                    const Color(0xFF3B82F6),
                                                    const Color(0xFF1E40AF),
                                                  ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (user?.name.isNotEmpty == true)
                                                ? user!.name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Name
                                  Text(
                                    user?.name ?? 'User Name',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Username
                                  Text(
                                    '@${user?.username ?? 'username'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subtextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Category / Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? const Color(0xFF1E56E2)
                                              .withValues(alpha: 0.1)
                                          : const Color(0xFF60A5FA)
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: user?.isOnline == true
                                                ? const Color(0xFF22C55E)
                                                : const Color(0xFF3B82F6),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          user?.category.isNotEmpty == true
                                              ? user!.category
                                              : 'Active User',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isLight
                                                ? const Color(0xFF1E56E2)
                                                : const Color(0xFF60A5FA),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // User Info Cards
                            _buildInfoTile(
                              icon: Icons.badge_outlined,
                              label: 'User ID',
                              value: user?.id.toString() ?? 'N/A',
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),
                            _buildInfoTile(
                              icon: Icons.storefront_outlined,
                              label: 'Branch / Territory ID (BID)',
                              value: user?.bid.toString() ?? 'N/A',
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),
                            _buildInfoTile(
                              icon: Icons.sync_rounded,
                              label: 'Last Master Sync Date',
                              value: lastSync,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),
                            _buildInfoTile(
                              icon: Icons.sensors_rounded,
                              label: 'Connection Status',
                              value: (user?.isOnline == true)
                                  ? 'Online (Connected)'
                                  : 'Offline / Cached Mode',
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),

                            const SizedBox(height: 28),

                            // Log Out Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () => _onLogout(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFF5252),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: const Color(0xFFFF5252)
                                      .withValues(alpha: 0.08),
                                ),
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 20,
                                  color: Color(0xFFFF5252),
                                ),
                                label: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Color(0xFFFF5252),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subtextColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E56E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E56E2), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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
