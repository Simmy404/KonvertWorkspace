import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../managers/theme_manager.dart';
import '../../services/storage_service.dart';
import 'dashboard_view_model.dart';
import '../../managers/location_manager.dart';
import '../place_order_screen.dart';
import '../login_screen.dart';
import '../../utils/page_transitions.dart';

class _DashboardGoogleMap extends StatefulWidget {
  final bool isDark;
  final Position position;

  const _DashboardGoogleMap({required this.isDark, required this.position});

  @override
  State<_DashboardGoogleMap> createState() => _DashboardGoogleMapState();
}

class _DashboardGoogleMapState extends State<_DashboardGoogleMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant _DashboardGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark && _mapController != null) {
      _mapController!.setMapStyle(
        widget.isDark ? ThemeManager.instance.darkMapStyle : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLatLng = LatLng(
      widget.position.latitude,
      widget.position.longitude,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: centerLatLng, zoom: 16.5),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      onMapCreated: (controller) {
        _mapController = controller;
        if (widget.isDark) {
          controller.setMapStyle(ThemeManager.instance.darkMapStyle);
        }
      },
      markers: {
        Marker(
          markerId: const MarkerId('current_location'),
          position: centerLatLng,
        ),
      },
      circles: {
        Circle(
          circleId: const CircleId('current_location_50m_range'),
          center: centerLatLng,
          radius: 100.0, // 50 meters geofence radius
          fillColor: const Color(0xFF1E56E2).withOpacity(0.18),
          strokeColor: const Color(0xFF1E56E2),
          strokeWidth: 2,
        ),
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  final VoidCallback onTriggerManualSync;

  const HomeTab({super.key, required this.onTriggerManualSync});

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
      final dashboardVM = Provider.of<DashboardViewModel>(
        context,
        listen: false,
      );
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 110,
      ), // Spacing for floating navbar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP COMPONENT: DEEP GRADIENT HEADER CARD
          _buildTopSection(context, isDark, currentUser, targets, dashboardVM),

          const SizedBox(height: 24),

          // BOTTOM SECTION: MY ACTIVITY & LOCATION MAP
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Activity Items
                _buildActivityCard(
                  title: 'Order Synchronization',
                  subtitle: 'All local bookings synced with server',
                  time: 'Just now',
                  icon: Icons.sync_rounded,
                  iconColor: const Color(0xFF388E3C),
                  isDark: isDark,
                ),
                _buildActivityCard(
                  title: 'GPS Location Ping',
                  subtitle: 'Active background location tracking',
                  time: '2 mins ago',
                  icon: Icons.my_location_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  isDark: isDark,
                ),
                _buildActivityCard(
                  title: 'Territory Catalog Update',
                  subtitle: 'Bricks & Customer lists up to date',
                  time: '1 hour ago',
                  icon: Icons.folder_copy_outlined,
                  iconColor: const Color(0xFFFB8C00),
                  isDark: isDark,
                ),
                _buildActivityCard(
                  title: 'Daily Route Target',
                  subtitle: 'On track to meet monthly target',
                  time: 'Today',
                  icon: Icons.track_changes_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Location Map (Google Maps)
                _buildGoogleMapCard(context, isDark),

                const SizedBox(height: 20),

                // Logout Button
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
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121318) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF22242E)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: locManager.isFetching
                  ? const CircularProgressIndicator(
                      color: Color(0xFF1E56E2),
                      strokeWidth: 2.5,
                    )
                  : Text(
                      'Location not available',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          );
        }

        return Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : const Color(0xFF003087).withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _DashboardGoogleMap(isDark: isDark, position: pos),
          ),
        );
      },
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
              ? [
                  const Color(0xFF0C164F),
                  const Color(0xFF050B30),
                  const Color(0xFF020414),
                ]
              : [
                  const Color(0xFF1E56E2),
                  const Color(0xFF1447C0),
                  const Color(0xFF0D369B),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : const Color(0xFF003087).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Mark
              Image.asset(
                ThemeManager.instance.getLogoMark(),
                width: 38,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.auto_awesome,
                  color: ThemeManager.instance.getMatchColor(),
                  size: 30,
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  IconButton(
                    onPressed: onTriggerManualSync,
                    icon: const Icon(
                      Icons.wb_sunny_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Master Sync',
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
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

          // User Greeting
          Text(
            currentUser?.name ?? 'Muhammad Asim',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getTimeAppropriateGreeting(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),

          // Target Header & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Overview',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
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
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                tooltip: 'Refresh Targets',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Target Metrics Grid
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
                    accentColor: const Color(0xFF4ADE80),
                  ),
                  _buildTargetMetricCard(
                    label: 'Total Sales',
                    value: targets['total_sales']?.toString() ?? '0',
                    icon: Icons.trending_up_rounded,
                    accentColor: const Color(0xFF60A5FA),
                  ),
                  _buildTargetMetricCard(
                    label: 'Today Sales',
                    value: targets['today_sales']?.toString() ?? '0',
                    icon: Icons.today_rounded,
                    accentColor: const Color(0xFFFBBF24),
                  ),
                  _buildTargetMetricCard(
                    label: 'No. of Orders',
                    value: targets['no_of_orders']?.toString() ?? '0',
                    icon: Icons.shopping_bag_outlined,
                    accentColor: const Color(0xFFC084FC),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary Place Order Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToPlaceOrder(context),
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
                backgroundColor: isDark
                    ? const Color(0xFF1E56E2)
                    : Colors.white,
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF1E56E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: isDark
                    ? const Color(0xFF1E56E2).withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
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
                    color: Colors.white.withOpacity(0.8),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121318) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF003087).withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
