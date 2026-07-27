// lib/screens/profile_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../managers/theme_manager.dart';
import '../managers/location_manager.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double gapRatio;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashCount = 16,
    this.gapRatio = 0.4,
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
    final dashRatio = (1.0 - gapRatio).clamp(0.1, 0.9);
    final dashLength = (circumference / dashCount) * dashRatio;
    final spaceLength = (circumference / dashCount) * gapRatio;

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
        oldDelegate.dashCount != dashCount ||
        oldDelegate.gapRatio != gapRatio;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showProfilePhotoOptions(BuildContext context) async {
    final bool hasCustomPfp =
        StorageService.instance.getProfilePicture()?.isNotEmpty == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeManager.instance.getContainerColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeManager.instance.getDividerColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeManager.instance.getTextPrimary(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF1E56E2),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: ThemeManager.instance.getTextPrimary(),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF1E56E2),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: TextStyle(
                      color: ThemeManager.instance.getTextPrimary(),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                if (hasCustomPfp)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFF5252),
                    ),
                    title: const Text(
                      'Remove Profile Picture',
                      style: TextStyle(color: Color(0xFFFF5252)),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await StorageService.instance.deleteProfilePicture();
                      ThemeManager.instance.notifyListeners();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        await StorageService.instance.saveProfilePicture(base64Str);
        ThemeManager.instance.notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile picture: $e');
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeManager.instance.getContainerColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Log Out',
            style: TextStyle(
              color: ThemeManager.instance.getTextPrimary(),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(
              color: ThemeManager.instance.getTextSecondary(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeManager.instance.getTextTertiary(),
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

  Widget _buildAvatarWidget(BuildContext context, bool isLight, User? user) {
    final String? pfpBase64 = StorageService.instance.getProfilePicture();

    Widget avatarContent;
    if (pfpBase64 != null && pfpBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(pfpBase64);
        avatarContent = ClipOval(
          child: Image.memory(
            bytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultAvatarContent(user),
          ),
        );
      } catch (_) {
        avatarContent = _buildDefaultAvatarContent(user);
      }
    } else {
      avatarContent = _buildDefaultAvatarContent(user);
    }

    return GestureDetector(
      onTap: () => _showProfilePhotoOptions(context),
      child: CustomPaint(
        painter: DashedCirclePainter(
          color: isLight ? const Color(0xFF1E56E2) : const Color(0xFF60A5FA),
          strokeWidth: 3.0,
          dashCount: 16,
          gapRatio: 0.4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isLight
                        ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                        : [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                  ),
                ),
                child: avatarContent,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarContent(User? user) {
    return Center(
      child: Text(
        (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = StorageService.instance.getCurrentUser();
    final String lastSync =
        StorageService.instance.getLastSyncDate() ?? 'Not Synced Yet';
    final String branchId = (user?.bid != null && user!.bid != 0)
        ? user.bid.toString()
        : (StorageService.instance.getApiKey() ?? 'N/A');

    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        final isLight = ThemeManager.instance.isLightMode;
        final textColor = ThemeManager.instance.getTextPrimary();
        final subtextColor = ThemeManager.instance.getTextSecondary();
        final cardBg = ThemeManager.instance.getContainerColor().withValues(alpha: 0.9);
        final borderColor = ThemeManager.instance.getDividerColor();

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
                                  _buildAvatarWidget(context, isLight, user),
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

                                  // Category, User ID & Branch ID Badges
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      // Category Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLight
                                              ? const Color(
                                                  0xFF1E56E2,
                                                ).withValues(alpha: 0.1)
                                              : const Color(
                                                  0xFF60A5FA,
                                                ).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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

                                      // User ID Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLight
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withValues(alpha: 0.1)
                                              : const Color(
                                                  0xFF34D399,
                                                ).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.badge_rounded,
                                              size: 14,
                                              color: isLight
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFF34D399),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'User ID: ${user?.id ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isLight
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFF34D399),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Branch ID Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLight
                                              ? const Color(
                                                  0xFFFF6B35,
                                                ).withValues(alpha: 0.1)
                                              : const Color(
                                                  0xFFFF8C5A,
                                                ).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.storefront_rounded,
                                              size: 14,
                                              color: isLight
                                                  ? const Color(0xFFFF6B35)
                                                  : const Color(0xFFFF8C5A),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Branch ID: $branchId',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isLight
                                                    ? const Color(0xFFFF6B35)
                                                    : const Color(0xFFFF8C5A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                              icon: Icons.category_outlined,
                              label: 'User Category',
                              value: user?.category.isNotEmpty == true
                                  ? user!.category
                                  : 'Active User',
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                            ),
                            _buildInfoTile(
                              icon: Icons.storefront_outlined,
                              label: 'Branch / Territory ID (BID)',
                              value: branchId,
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

                            const SizedBox(height: 24),

                            // Preferences & Settings Section Header
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 12),
                                child: Text(
                                  'App Preferences & Settings',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),

                            // 1. App Theme Option Tile
                            _buildThemePreferenceTile(
                              context: context,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              isLight: isLight,
                            ),

                            // 2. Location Precision Option Tile
                            _buildLocationPrecisionTile(
                              context: context,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              isLight: isLight,
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
                                  backgroundColor: const Color(
                                    0xFFFF5252,
                                  ).withValues(alpha: 0.08),
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

  Widget _buildThemePreferenceTile({
    required BuildContext context,
    required Color textColor,
    required Color subtextColor,
    required Color cardBg,
    required Color borderColor,
    required bool isLight,
  }) {
    final currentTheme = ThemeManager.instance.currentTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E56E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette_outlined, color: Color(0xFF1E56E2), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Theme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select visual theme style',
                      style: TextStyle(
                        fontSize: 12,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildThemeOptionChip(
                label: 'Accent',
                icon: Icons.light_mode_rounded,
                isSelected: currentTheme == Themes.accent,
                onTap: () => ThemeManager.instance.setThemeStyle(Themes.accent),
                textColor: textColor,
                subtextColor: subtextColor,
                isLight: isLight,
              ),
              const SizedBox(width: 8),
              _buildThemeOptionChip(
                label: 'Neon',
                icon: Icons.dark_mode_rounded,
                isSelected: currentTheme == Themes.neon,
                onTap: () => ThemeManager.instance.setThemeStyle(Themes.neon),
                textColor: textColor,
                subtextColor: subtextColor,
                isLight: isLight,
              ),
              const SizedBox(width: 8),
              _buildThemeOptionChip(
                label: 'Default',
                icon: Icons.brightness_auto_rounded,
                isSelected: currentTheme == Themes.system,
                onTap: () => ThemeManager.instance.setThemeStyle(Themes.system),
                textColor: textColor,
                subtextColor: subtextColor,
                isLight: isLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
    required Color subtextColor,
    required bool isLight,
  }) {
    final activeColor = const Color(0xFF1E56E2);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isLight ? 0.12 : 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : subtextColor.withValues(alpha: 0.3),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeColor : subtextColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPrecisionTile({
    required BuildContext context,
    required Color textColor,
    required Color subtextColor,
    required Color cardBg,
    required Color borderColor,
    required bool isLight,
  }) {
    return ListenableBuilder(
      listenable: LocationManager.instance,
      builder: (context, child) {
        final currentPrecision = LocationManager.instance.precision;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Precision',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GPS accuracy for Dashboard Map & Place Order',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildPrecisionOptionChip(
                    label: 'Normal',
                    subtitle: 'Balanced GPS',
                    icon: Icons.location_on_outlined,
                    isSelected: currentPrecision == 'normal',
                    onTap: () => LocationManager.instance.setPrecision('normal'),
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isLight: isLight,
                  ),
                  const SizedBox(width: 10),
                  _buildPrecisionOptionChip(
                    label: 'High',
                    subtitle: 'High Precision GPS',
                    icon: Icons.my_location_rounded,
                    isSelected: currentPrecision == 'high',
                    onTap: () => LocationManager.instance.setPrecision('high'),
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isLight: isLight,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrecisionOptionChip({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
    required Color subtextColor,
    required bool isLight,
  }) {
    final activeColor = const Color(0xFF10B981);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isLight ? 0.12 : 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : subtextColor.withValues(alpha: 0.3),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? activeColor : subtextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? activeColor : textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? activeColor.withValues(alpha: 0.85) : subtextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
