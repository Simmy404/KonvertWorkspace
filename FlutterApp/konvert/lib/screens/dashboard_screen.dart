import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'master_sync_screen.dart';
import 'bookings_screen.dart';

import 'dashboard/dashboard_view_model.dart';
import 'dashboard/tour_plan_view_model.dart';
import 'dashboard/report_view_model.dart';
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
  late TourPlanViewModel _tourPlanViewModel;
  late ReportViewModel _reportViewModel;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _tourPlanViewModel = TourPlanViewModel();
    _reportViewModel = ReportViewModel();
    _pageController = PageController(initialPage: _viewModel.selectedIndex);
    _viewModel.addListener(_onViewModelChanged);

    // Defer the check so it doesn't interrupt the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSync();
    });
  }

  void _onViewModelChanged() {
    if (_pageController.hasClients &&
        _pageController.page?.round() != _viewModel.selectedIndex) {
      _pageController.animateToPage(
        _viewModel.selectedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _pageController.dispose();
    super.dispose();
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

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeManager.instance.getAppBackgroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit Application',
            style: TextStyle(
              color: ThemeManager.instance.getTextPrimary(),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to close the app?',
            style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeManager.instance.getTextSecondary(),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: _tourPlanViewModel),
        ChangeNotifierProvider.value(value: _reportViewModel),
      ],
      child: ListenableBuilder(
        listenable: ThemeManager.instance,
        builder: (context, child) {
          return Consumer<DashboardViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.needsInitialSync) {
                return const Scaffold(backgroundColor: Colors.black);
              }

              return PopScope(
                canPop: false,
                onPopInvoked: (didPop) async {
                  if (didPop) return;
                  final shouldPop = await _onWillPop(context);
                  if (shouldPop) {
                    if (context.mounted) {
                      SystemNavigator.pop();
                    }
                  }
                },
                child: Scaffold(
                  backgroundColor: ThemeManager.instance.getAppBackgroundColor(),
                  body: Stack(
                    children: [
                      // Main Theme Background Image covering the entire dashboard screen
                      Positioned.fill(
                        child: Image.asset(
                          ThemeManager.instance.getMainBG(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: ThemeManager.instance.getAppBackgroundColor(),
                              ),
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                if (_viewModel.selectedIndex != index) {
                                  _viewModel.setSelectedIndex(index);
                                }
                              },
                              children: [
                                HomeTab(
                                  onTriggerManualSync: _triggerManualSync,
                                ),
                                const BookingsScreen(),
                                const TourPlanTab(),
                                const ReportTab(),
                              ],
                            ),
                          ),

                          // Bottom Navigation Bar Area
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                              child: _buildBottomNavBar(
                                context,
                                viewModel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        gradient: ThemeManager.instance.getNavBarGradient(),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: ThemeManager.instance.isLightMode
                ? const Color(0xFF003087).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              viewModel,
              index: 0,
              selectedIcon: Icons.space_dashboard_rounded,
              unselectedIcon: Icons.space_dashboard_outlined,
              label: 'Home',
            ),
            _buildNavItem(
              viewModel,
              index: 1,
              selectedIcon: Icons.shopping_bag_rounded,
              unselectedIcon: Icons.shopping_bag_outlined,
              label: 'Bookings',
            ),
            _buildNavItem(
              viewModel,
              index: 2,
              selectedIcon: Icons.explore_rounded,
              unselectedIcon: Icons.explore_outlined,
              label: 'Tour Plan',
            ),
            _buildNavItem(
              viewModel,
              index: 3,
              selectedIcon: Icons.analytics_rounded,
              unselectedIcon: Icons.analytics_outlined,
              label: 'Report',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    DashboardViewModel viewModel, {
    required int index,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
  }) {
    final isSelected = viewModel.selectedIndex == index;

    final Color selectedPillBg = ThemeManager.instance.isLightMode
        ? const Color(0xFF0A192F).withValues(alpha: 0.12)
        : const Color(0xFF0059FF).withValues(alpha: 0.20);

    final Color selectedContentColor = ThemeManager.instance.isLightMode
        ? const Color(0xFF0A192F)
        : const Color(0xFFE0F2FE);

    final Color unselectedContentColor = ThemeManager.instance.isLightMode
        ? const Color(0xFF0A192F).withValues(alpha: 0.35)
        : const Color(0xFFE0F2FE).withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () => viewModel.setSelectedIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: selectedPillBg,
                borderRadius: BorderRadius.circular(22),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? selectedContentColor : unselectedContentColor,
              size: isSelected ? 22 : 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedContentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
