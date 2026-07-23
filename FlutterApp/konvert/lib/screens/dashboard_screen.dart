// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../utils/page_transitions.dart';
import 'master_sync_screen.dart';
import 'place_order_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool fromLogin;

  const DashboardScreen({
    super.key,
    this.fromLogin = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _needsInitialSync = false;
  int _selectedIndex = 0; // Navbar index: 0 = Home, 1 = Bookings, 2 = Tour Plan, 3 = Report

  int _bricksCount = 0;
  int _productsCount = 0;
  int _chemistsCount = 0;
  bool _loadingCounts = true;

  @override
  void initState() {
    super.initState();
    _checkInitialSync();
    if (!_needsInitialSync) {
      _loadCatalogCounts();
    }
  }

  void _checkInitialSync() {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final lastSyncDate = StorageService.instance.getLastSyncDate();

    // Condition a) User came here from login screen
    // Condition b) User opened the app for the first time today
    final bool isFirstOpenToday = (lastSyncDate != todayStr);

    if (widget.fromLogin || isFirstOpenToday) {
      _needsInitialSync = true;

      // Push instantly to Master Sync after the layout initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageTransitions.instantTransition(const MasterSyncScreen()),
          );
        }
      });
    }
  }

  Future<void> _loadCatalogCounts() async {
    try {
      final bricks = await DatabaseService.instance.getBricksCount();
      final products = await DatabaseService.instance.getProductsCount();
      final chemists = await DatabaseService.instance.getChemistsCount();

      if (mounted) {
        setState(() {
          _bricksCount = bricks;
          _productsCount = products;
          _chemistsCount = chemists;
          _loadingCounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCounts = false);
      }
    }
  }

  void _triggerManualSync() {
    Navigator.push(
      context,
      PageTransitions.fadeTransition(const MasterSyncScreen()),
    ).then((_) {
      _loadCatalogCounts();
    });
  }

  void _navigateToPlaceOrder() {
    Navigator.push(
      context,
      PageTransitions.fadeTransition(const PlaceOrderScreen()),
    );
  }

  Future<void> _onLogout() async {
    await StorageService.instance.logoutUser();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeTransition(const LoginScreen()),
    );
  }

  String _getTimeAppropriateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 👋';
    } else if (hour < 17) {
      return 'Good Afternoon 👋';
    } else if (hour < 21) {
      return 'Good Evening 👋';
    } else {
      return 'Good Night 👋';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsInitialSync) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final isDark = !ThemeManager.instance.isLightMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Page content switching seamlessly based on _selectedIndex
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(isDark),
                  _buildBookingsTab(isDark),
                  _buildTourPlanTab(isDark),
                  _buildReportTab(isDark),
                ],
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _buildBottomNavBar(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: HOME / DASHBOARD TAB
  // ==========================================
  Widget _buildHomeTab(bool isDark) {
    final currentUser = StorageService.instance.getCurrentUser();
    final targets = StorageService.instance.getTargets();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // padding for navbar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------
          // TOP SECTION (Gradients, Header, Targets, Place Order)
          // ----------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0B1437),
                        const Color(0xFF070B24),
                        const Color(0xFF030514),
                      ]
                    : [
                        const Color(0xFFEAF2FF),
                        const Color(0xFFD6E6FF),
                        const Color(0xFFC7DCFF),
                      ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1B285E).withOpacity(0.5)
                    : Colors.white.withOpacity(0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : const Color(0xFF003087).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Logo, Sync Button, Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      ThemeManager.instance.getLogoMark(),
                      width: 40,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.auto_awesome,
                        color: ThemeManager.instance.getMatchColor(),
                        size: 32,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _triggerManualSync,
                          icon: Icon(
                            Icons.wb_sunny_outlined,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 22,
                          ),
                          tooltip: 'Master Sync',
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 24,
                              ),
                              tooltip: 'Notifications',
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5252),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Greeting & Name
                Text(
                  currentUser?.name ?? 'Muhammad Asim',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAppropriateGreeting(),
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF475569),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // 4 Target Details Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.85,
                  children: [
                    _buildTargetMetricCard(
                      label: 'Month Target',
                      value: targets['month_target'] ?? '0',
                      icon: Icons.track_changes_rounded,
                      accentColor: const Color(0xFF388E3C),
                      isDark: isDark,
                    ),
                    _buildTargetMetricCard(
                      label: 'Total Sales',
                      value: targets['total_sales'] ?? '0',
                      icon: Icons.trending_up_rounded,
                      accentColor: const Color(0xFF1E88E5),
                      isDark: isDark,
                    ),
                    _buildTargetMetricCard(
                      label: 'Today Sales',
                      value: targets['today_sales'] ?? '0',
                      icon: Icons.today_rounded,
                      accentColor: const Color(0xFFFB8C00),
                      isDark: isDark,
                    ),
                    _buildTargetMetricCard(
                      label: 'No. of Orders',
                      value: targets['no_of_orders'] ?? '0',
                      icon: Icons.shopping_bag_outlined,
                      accentColor: const Color(0xFF8E24AA),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Place Order Button inside Top Section
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToPlaceOrder,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    label: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E56E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ----------------------------------------
          // BOTTOM HALF: MY ACTIVITY SECTION
          // ----------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'My Activity',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4 Activity Cards matching screenshot layout
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),

                const SizedBox(height: 16),

                // Logout Button
                _buildLogoutButton(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logout Button Helper
  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _onLogout,
        icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFFF5252)),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFFF5252),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFFFF5252).withOpacity(0.4),
            width: 1.5,
          ),
          backgroundColor: isDark
              ? const Color(0xFFFF5252).withOpacity(0.08)
              : const Color(0xFFFF5252).withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Target Metric Card Helper
  Widget _buildTargetMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A1435).withOpacity(0.6)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E2D68).withOpacity(0.5)
              : const Color(0xFFB8D5FF).withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // Activity Card Helper
  Widget _buildActivityCard(bool isDark) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121318) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF22242E)
              : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BOOKINGS TAB (SWITCHES ON SAME PAGE)
  // ==========================================
  Widget _buildBookingsTab(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'View and manage your order bookings',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: TOUR PLAN TAB (SWITCHES ON SAME PAGE)
  // ==========================================
  Widget _buildTourPlanTab(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Plan',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Assigned bricks and daily route plan',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tour Plan ($_bricksCount Bricks Synced)',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: REPORT TAB (SWITCHES ON SAME PAGE)
  // ==========================================
  Widget _buildReportTab(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Analytics and performance summary',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Reports & Analytics coming soon',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLOATING BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0B1953),
                  const Color(0xFF050E36),
                ]
              : [
                  const Color(0xFF1E56E2),
                  const Color(0xFF0D3BB3),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E358A)
              : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : const Color(0xFF003087).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.receipt_long_rounded,
            label: 'Bookings',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.map_rounded,
            label: 'Tour Plan',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.bar_chart_rounded,
            label: 'Report',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}