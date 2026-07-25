import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
import '../profile_screen.dart';
import '../../utils/page_transitions.dart';

// ==========================================
// DASHBOARD GOOGLE MAP (EXTRACTED STATEFUL)
// ==========================================
class _DashboardGoogleMap extends StatefulWidget {
  final bool isDark;
  final Position position;

  const _DashboardGoogleMap({required this.isDark, required this.position});

  @override
  State<_DashboardGoogleMap> createState() => _DashboardGoogleMapState();
}

class _DashboardGoogleMapState extends State<_DashboardGoogleMap> {
  GoogleMapController? _mapController;

  void _resetCamera() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.position.latitude, widget.position.longitude),
            zoom: 16.5,
          ),
        ),
      );
    }
  }

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

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: centerLatLng,
            zoom: 16.5,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
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
              radius: 100.0,
              fillColor: const Color(0xFF1E56E2).withValues(alpha: 0.18),
              strokeColor: const Color(0xFF1E56E2),
              strokeWidth: 2,
            ),
          },
        ),

        // Reset Camera / Re-center Position Button
        Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _resetCamera,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF121318).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  size: 18,
                  color: widget.isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF1E56E2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// HOME TAB
// ==========================================
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

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.fadeTransition(const ProfileScreen()),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // TOP SECTION: BACKGROUND IMAGE AREA
          // ==========================================
          _buildTopSection(context, isDark, currentUser, targets, dashboardVM),

          // ==========================================
          // BOTTOM SECTION: MY ACTIVITY & LOGOUT
          // ==========================================
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
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
                          fontSize: 18,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP SECTION WITH BACKGROUND IMAGE
  // ==========================================
  Widget _buildTopSection(
    BuildContext context,
    bool isDark,
    dynamic currentUser,
    Map<String, dynamic> targets,
    DashboardViewModel dashboardVM,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Image Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : const Color(0xFF003087).withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Stack(
              children: [
                // Background Image (stretched to fill)
                Positioned.fill(
                  child: Image.asset(
                    ThemeManager.instance.getDashboardMain(),
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
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
                      ),
                    ),
                  ),
                ),

                // Content over the background
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 12,
                    20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Action Row: Logo + Icons
                      _buildTopActionBar(),
                      const SizedBox(height: 24),

                      // User Greeting with Avatar
                      _buildUserGreeting(context, currentUser),
                      const SizedBox(height: 24),

                      // Target Overview Header
                      Text(
                        'Target Overview',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Target Metric Cards (Horizontal Row)
                      IgnorePointer(
                        ignoring: dashboardVM.isRefreshingTargets,
                        child: Opacity(
                          opacity: dashboardVM.isRefreshingTargets ? 0.5 : 1.0,
                          child: _buildTargetCardsRow(targets, isDark),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Google Maps Card
                      _buildGoogleMapCard(context, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating "+" Place Order Button (overlapping the bottom edge)
        Positioned(
          bottom: -32,
          left: 0,
          right: 0,
          child: Center(child: _buildPlaceOrderFAB(context, isDark)),
        ),
      ],
    );
  }

  // ==========================================
  // TOP ACTION BAR: LOGO + SYNC + NOTIFICATION
  // ==========================================
  Widget _buildTopActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo Mark
        Image.asset(
          ThemeManager.instance.logoMarkDark,
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
    );
  }

  // ==========================================
  // USER GREETING WITH AVATAR
  // ==========================================
  Widget _buildUserGreeting(BuildContext context, dynamic currentUser) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Dashed Profile Avatar Circle
          CustomPaint(
            painter: DashedCirclePainter(
              color: const Color(0xFFFF6B35),
              strokeWidth: 2.5,
              dashCount: 14,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser?.name ?? 'Muhammad Asim',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
              Text(
                _getTimeAppropriateGreeting(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TARGET CARDS (HORIZONTAL ROW)
  // ==========================================
  Widget _buildTargetCardsRow(Map<String, dynamic> targets, bool isDark) {
    String formatValue(String raw) {
      final cleaned = raw.replaceAll(',', '').trim();
      final val = double.tryParse(cleaned) ?? 0;
      if (val >= 1000000) {
        final m = val / 1000000;
        if (m == m.roundToDouble()) {
          return '${m.toInt()}M';
        }
        return '${m.toStringAsFixed(1)}M';
      } else if (val >= 1000) {
        final k = val / 1000;
        if (k == k.roundToDouble()) {
          return '${k.toInt()}K';
        }
        return '${k.toStringAsFixed(1)}K';
      }
      if (val == val.roundToDouble()) {
        return val.toInt().toString();
      }
      return val.toStringAsFixed(1);
    }

    return Row(
      children: [
        Expanded(
          child: _buildTargetCard(
            value: formatValue(targets['month_target']?.toString() ?? '0'),
            label: 'Monthly\nTarget',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            value: formatValue(targets['total_sales']?.toString() ?? '0'),
            label: 'Total\nSales',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            value: formatValue(targets['today_sales']?.toString() ?? '0'),
            label: 'Today\nSales',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            value: formatValue(targets['no_of_orders']?.toString() ?? '0'),
            label: 'No. of\nOrders',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCard({
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        gradient: ThemeManager.instance.getTargetCardGradient(isDark: isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: ThemeManager.instance.getTargetCardValueColor(
                isDark: isDark,
              ),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeManager.instance.getTargetCardLabelColor(
                isDark: isDark,
              ),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GOOGLE MAPS CARD
  // ==========================================
  Widget _buildGoogleMapCard(BuildContext context, bool isDark) {
    return Consumer<LocationManager>(
      builder: (context, locManager, child) {
        final pos = locManager.currentPosition;
        if (pos == null) {
          return Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF121318).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
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
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _DashboardGoogleMap(isDark: isDark, position: pos),
          ),
        );
      },
    );
  }

  // ==========================================
  // FLOATING "+" PLACE ORDER BUTTON
  // ==========================================
  Widget _buildPlaceOrderFAB(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToPlaceOrder(context),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThemeManager.instance.getPlaceOrderGradient(isDark: isDark),
          border: Border.all(
            color: ThemeManager.instance.getPlaceOrderBorderColor(
              isDark: isDark,
            ),
            width: 3,
          ),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  // ==========================================
  // ACTIVITY CARD
  // ==========================================
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
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF003087).withValues(alpha: 0.04),
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
              color: iconColor.withValues(alpha: 0.12),
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
}
