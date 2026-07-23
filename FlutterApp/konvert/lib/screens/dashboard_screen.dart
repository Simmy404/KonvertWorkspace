import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'master_sync_screen.dart';
import 'bookings_screen.dart';

import 'dashboard/dashboard_view_model.dart';
import 'dashboard/home_tab.dart';
import 'dashboard/tour_plan_tab.dart';
import 'dashboard/report_tab.dart';

class DashboardScreen extends StatefulWidget {
  final bool fromLogin;

  const DashboardScreen({super.key, this.fromLogin = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();

    // Defer the check so it doesn't interrupt the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSync();
    });
  }

  void _checkInitialSync() {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final lastSyncDate = StorageService.instance.getLastSyncDate();

    final bool isFirstOpenToday = (lastSyncDate != todayStr);

    if (widget.fromLogin || isFirstOpenToday) {
      _viewModel.setNeedsInitialSync(true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageTransitions.instantTransition(const MasterSyncScreen()),
        );
      }
    }
  }

  void _triggerManualSync() {
    Navigator.push(
      context,
      PageTransitions.fadeTransition(const MasterSyncScreen()),
    ).then((_) {
      _viewModel.loadCatalogCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.needsInitialSync) {
            return const Scaffold(backgroundColor: Colors.black);
          }

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF030305)
                : const Color(0xFFF4F6F9),
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: viewModel.selectedIndex,
                      children: [
                        HomeTab(onTriggerManualSync: _triggerManualSync),
                        const BookingsScreen(),
                        const TourPlanTab(),
                        const ReportTab(),
                      ],
                    ),
                  ),

                  // Bottom Navigation Bar
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: _buildBottomNavBar(context, viewModel, isDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar(
    BuildContext context,
    DashboardViewModel viewModel,
    bool isDark,
  ) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0B1953), const Color(0xFF050E36)]
              : [const Color(0xFF1E56E2), const Color(0xFF0D3BB3)],
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
            viewModel,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          _buildNavItem(
            viewModel,
            index: 1,
            icon: Icons.receipt_long_rounded,
            label: 'Bookings',
          ),
          _buildNavItem(
            viewModel,
            index: 2,
            icon: Icons.map_rounded,
            label: 'Tour Plan',
          ),
          _buildNavItem(
            viewModel,
            index: 3,
            icon: Icons.bar_chart_rounded,
            label: 'Report',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    DashboardViewModel viewModel, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = viewModel.selectedIndex == index;

    return GestureDetector(
      onTap: () => viewModel.setSelectedIndex(index),
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
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: isSelected ? 24 : 22,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
