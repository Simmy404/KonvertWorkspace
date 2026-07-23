import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../managers/theme_manager.dart';
import '../../services/storage_service.dart';
import 'dashboard_view_model.dart';
import '../../managers/location_manager.dart';
import '../place_order_screen.dart';
import '../login_screen.dart';
import '../../utils/page_transitions.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onTriggerManualSync;

  const HomeTab({
    super.key,
    required this.onTriggerManualSync,
  });

  String _getTimeAppropriateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    if (hour < 21) return 'Good Evening 👋';
    return 'Good Night 👋';
  }

  Future<void> _navigateToPlaceOrder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageTransitions.fadeTransition(const PlaceOrderScreen()),
    );
    if (result == true && context.mounted) {
      final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);
      dashboardVM.loadCatalogCounts();
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    await StorageService.instance.logoutUser();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeTransition(const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = StorageService.instance.getCurrentUser();
    final targets = StorageService.instance.getTargets();
    final dashboardVM = context.watch<DashboardViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // padding for navbar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP SECTION
          _buildTopSection(context, isDark, currentUser, targets, dashboardVM),

          const SizedBox(height: 24),

          // BOTTOM HALF: MY ACTIVITY SECTION
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
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),
                _buildActivityCard(isDark),

                const SizedBox(height: 16),
                
                // Location Map (Google Maps)
                _buildGoogleMapCard(context, isDark),
                
                const SizedBox(height: 16),
                _buildLogoutButton(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoogleMapCard(BuildContext context, bool isDark) {
    return Consumer<LocationManager>(
      builder: (context, locManager, child) {
        final pos = locManager.currentPosition;
        if (pos == null) {
          return Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121318) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: locManager.isFetching 
                ? const CircularProgressIndicator()
                : Text('Location not available', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
            ),
          );
        }
        
        return Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(pos.latitude, pos.longitude),
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(pos.latitude, pos.longitude),
                )
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    bool isDark,
    dynamic currentUser,
    Map<String, dynamic> targets,
    DashboardViewModel dashboardVM,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0B1437), const Color(0xFF070B24), const Color(0xFF030514)]
              : [const Color(0xFFEAF2FF), const Color(0xFFD6E6FF), const Color(0xFFC7DCFF)],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        border: Border.all(
          color: isDark ? const Color(0xFF1B285E).withOpacity(0.5) : Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.5) : const Color(0xFF003087).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    onPressed: onTriggerManualSync,
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
                          decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
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
              color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Target Header & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Overview',
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: dashboardVM.isRefreshingTargets
                    ? null
                    : () => dashboardVM.refreshTargets(),
                icon: dashboardVM.isRefreshingTargets
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1E56E2),
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                        size: 18,
                      ),
                tooltip: 'Refresh Targets',
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Target Grid (Disabled while refreshing)
          IgnorePointer(
            ignoring: dashboardVM.isRefreshingTargets,
            child: Opacity(
              opacity: dashboardVM.isRefreshingTargets ? 0.5 : 1.0,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.85,
                children: [
                  _buildTargetMetricCard(
                    label: 'Month Target',
                    value: targets['month_target']?.toString() ?? '0',
                    icon: Icons.track_changes_rounded,
                    accentColor: const Color(0xFF388E3C),
                    isDark: isDark,
                  ),
                  _buildTargetMetricCard(
                    label: 'Total Sales',
                    value: targets['total_sales']?.toString() ?? '0',
                    icon: Icons.trending_up_rounded,
                    accentColor: const Color(0xFF1E88E5),
                    isDark: isDark,
                  ),
                  _buildTargetMetricCard(
                    label: 'Today Sales',
                    value: targets['today_sales']?.toString() ?? '0',
                    icon: Icons.today_rounded,
                    accentColor: const Color(0xFFFB8C00),
                    isDark: isDark,
                  ),
                  _buildTargetMetricCard(
                    label: 'No. of Orders',
                    value: targets['no_of_orders']?.toString() ?? '0',
                    icon: Icons.shopping_bag_outlined,
                    accentColor: const Color(0xFF8E24AA),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToPlaceOrder(context),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text(
                'Place Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E56E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        color: isDark ? const Color(0xFF0A1435).withOpacity(0.6) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D68).withOpacity(0.5) : const Color(0xFFB8D5FF).withOpacity(0.6),
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
                    color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF475569),
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

  Widget _buildActivityCard(bool isDark) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121318) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _onLogout(context),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
