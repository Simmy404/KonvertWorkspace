import 'dart:convert';
import 'dart:math' as math;
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
import '../notifications/notifications_screen.dart';

// ==========================================
// DASHBOARD GOOGLE MAP (EXTRACTED STATEFUL)
// ==========================================
class _DashboardGoogleMap extends StatefulWidget {
  final Position position;

  const _DashboardGoogleMap({required this.position});

  @override
  State<_DashboardGoogleMap> createState() => _DashboardGoogleMapState();
}

class _DashboardGoogleMapState extends State<_DashboardGoogleMap> {
  GoogleMapController? _mapController;
  double? _lastRadius;

  double _calculateZoomForRadius(double radiusInMeters) {
    final zoom = 16.5 - (math.log(radiusInMeters / 100.0) / math.ln2);
    return zoom.clamp(11.5, 18.5);
  }

  LatLngBounds _boundsFromRadius(LatLng center, double radiusInMeters) {
    final paddedRadius = radiusInMeters * 1.35;
    final lat = center.latitude;
    final lng = center.longitude;

    final latDelta = paddedRadius / 111320.0;
    final lngDelta = paddedRadius / (111320.0 * math.cos(lat * math.pi / 180.0));

    return LatLngBounds(
      southwest: LatLng(lat - latDelta, lng - lngDelta),
      northeast: LatLng(lat + latDelta, lng + lngDelta),
    );
  }

  void _fitMapToCircle(double radius) {
    if (_mapController != null) {
      final center = LatLng(widget.position.latitude, widget.position.longitude);
      try {
        final bounds = _boundsFromRadius(center, radius);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 20.0),
        );
      } catch (_) {
        final zoom = _calculateZoomForRadius(radius);
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: center, zoom: zoom),
          ),
        );
      }
    }
  }

  void _resetCamera() {
    final radius = LocationManager.instance.geofenceRadius;
    _fitMapToCircle(radius);
  }

  @override
  void didUpdateWidget(covariant _DashboardGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapController != null) {
      _mapController!.setMapStyle(
        ThemeManager.instance.isLightMode
            ? null
            : ThemeManager.instance.darkMapStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocationManager.instance,
      builder: (context, _) {
        final centerLatLng = LatLng(
          widget.position.latitude,
          widget.position.longitude,
        );
        final radius = LocationManager.instance.geofenceRadius;

        if (_lastRadius != radius) {
          _lastRadius = radius;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitMapToCircle(radius);
          });
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: centerLatLng,
                zoom: _calculateZoomForRadius(radius),
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
                if (!ThemeManager.instance.isLightMode) {
                  controller.setMapStyle(ThemeManager.instance.darkMapStyle);
                }
                _fitMapToCircle(radius);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: centerLatLng,
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId('current_location_geofence_range'),
                  center: centerLatLng,
                  radius: radius,
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
                      color: ThemeManager.instance.isLightMode
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF121318).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ThemeManager.instance.isLightMode
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.15),
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
                      color: ThemeManager.instance.isLightMode
                          ? const Color(0xFF1E56E2)
                          : const Color(0xFF60A5FA),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

  Future<void> _navigateToProfile(BuildContext context) async {
    await Navigator.push(
      context,
      PageTransitions.fadeTransition(const ProfileScreen()),
    );
    if (context.mounted) {
      final dashboardVM = Provider.of<DashboardViewModel>(
        context,
        listen: false,
      );
      dashboardVM.loadCatalogCounts();
      dashboardVM.refreshTargets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        final currentUser = StorageService.instance.getCurrentUser();
        final targets = StorageService.instance.getTargets();
        final dashboardVM = context.watch<DashboardViewModel>();

        return RefreshIndicator(
          onRefresh: () async {
            await dashboardVM.refreshTargets();
            await dashboardVM.loadCatalogCounts();
          },
          color: const Color(0xFF1E56E2),
          backgroundColor: ThemeManager.instance.getContainerColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // TOP SECTION: BACKGROUND IMAGE AREA
                // ==========================================
                _buildTopSection(context, currentUser, targets, dashboardVM),

                // ==========================================
                // BOTTOM SECTION: MY ACTIVITY & LOGOUT
                // ==========================================
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                                color: ThemeManager.instance.getTextPrimary(),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: ThemeManager.instance.getTextPrimary(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Activity Items (4 Empty Cards)
                      _buildActivityCard(),
                      _buildActivityCard(),
                      _buildActivityCard(),
                      _buildActivityCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TOP SECTION WITH BACKGROUND IMAGE
  // ==========================================
  Widget _buildTopSection(
    BuildContext context,
    dynamic currentUser,
    Map<String, dynamic> targets,
    DashboardViewModel dashboardVM,
  ) {
    return Stack(
      children: [
        // Main Column defining Stack height (Image Container + 32px bottom space for FAB)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeManager.instance.isLightMode
                        ? const Color(0xFF003087).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.6),
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
                              colors: ThemeManager.instance.isLightMode
                                  ? [
                                      const Color(0xFF1E56E2),
                                      const Color(0xFF1447C0),
                                      const Color(0xFF0D369B),
                                    ]
                                  : [
                                      const Color(0xFF0C164F),
                                      const Color(0xFF050B30),
                                      const Color(0xFF020414),
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
                          // Top Action Bar: Logo + Icons
                          _buildTopActionBar(context),
                          const SizedBox(height: 24),

                          // User Greeting with Avatar
                          _buildUserGreeting(context, currentUser),
                          const SizedBox(height: 24),

                          // Target Overview Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target Overview',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (dashboardVM.isRefreshingTargets)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70,
                                    ),
                                  ),
                                )
                              else
                                InkWell(
                                  onTap: () => dashboardVM.refreshTargets(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Target Metric Cards (Horizontal Row)
                          IgnorePointer(
                            ignoring: dashboardVM.isRefreshingTargets,
                            child: Opacity(
                              opacity: dashboardVM.isRefreshingTargets
                                  ? 0.5
                                  : 1.0,
                              child: _buildTargetCardsRow(targets),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Google Maps Card
                          _buildGoogleMapCard(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 32px space so the FAB stays 100% within the Stack layout & hit-test bounds
            const SizedBox(height: 32),
          ],
        ),

        // Floating "+" Place Order Button (overlapping the bottom edge, 100% inside Stack bounds)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(child: _buildPlaceOrderFAB(context)),
        ),
      ],
    );
  }

  // ==========================================
  // TOP ACTION BAR: LOGO + SYNC + NOTIFICATION
  // ==========================================
  Widget _buildTopActionBar(BuildContext context) {
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
            StatefulBuilder(
              builder: (context, setState) {
                final hasUnread = StorageService.instance
                    .hasUnreadNotifications();
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransitions.fadeTransition(
                            const NotificationsScreen(),
                          ),
                        );
                        if (context.mounted) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      tooltip: 'Notifications',
                    ),
                    if (hasUnread)
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
                );
              },
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
    final String? pfpBase64 = StorageService.instance.getProfilePicture();

    Widget avatarChild;
    if (pfpBase64 != null && pfpBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(pfpBase64);
        avatarChild = ClipOval(
          child: Image.memory(
            bytes,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        );
      } catch (_) {
        avatarChild = const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 26,
        );
      }
    } else {
      avatarChild = const Icon(
        Icons.person_outline_rounded,
        color: Colors.white,
        size: 26,
      );
    }

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
              dashCount: 10,
              gapRatio: 0.4,
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
                child: Center(child: avatarChild),
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
  Widget _buildTargetCardsRow(Map<String, dynamic> targets) {
    ({String number, String unit}) formatValueParts(String raw) {
      final cleaned = raw.replaceAll(',', '').trim();
      final val = double.tryParse(cleaned) ?? 0;
      if (val <= 0) return (number: '0', unit: '');

      if (val >= 100000) {
        // >= 100K -> convert to Millions (e.g. 294k -> 0.29M, 340k -> 0.34M, 1.5M, 12M)
        final m = val / 1000000;
        if (m >= 1000) {
          final b = val / 1000000000;
          if (b >= 10) {
            return (number: '${b.round()}', unit: 'B');
          }
          final str = b.toStringAsFixed(1);
          return (number: str.endsWith('.0') ? '${b.toInt()}' : str, unit: 'B');
        }
        if (m >= 100) {
          return (number: '${m.round()}', unit: 'M');
        }
        if (m >= 10) {
          final str = m.toStringAsFixed(1);
          return (number: str.endsWith('.0') ? '${m.toInt()}' : str, unit: 'M');
        }
        // m is 0.10 to 9.99 (up to 2 decimals, max 5 chars total e.g. 0.29M, 0.34M)
        var str = m.toStringAsFixed(2);
        if (str.endsWith('0')) {
          str = m.toStringAsFixed(1);
        }
        if (str.endsWith('.0')) {
          str = '${m.toInt()}';
        }
        return (number: str, unit: 'M');
      } else if (val >= 1000) {
        // 1K to 99.9K
        final k = val / 1000;
        if (k >= 100) {
          return (number: '${k.round()}', unit: 'K');
        }
        if (k >= 10) {
          final str = k.toStringAsFixed(1);
          return (number: str.endsWith('.0') ? '${k.toInt()}' : str, unit: 'K');
        }
        // k is 1.00 to 9.99
        var str = k.toStringAsFixed(2);
        if (str.endsWith('0')) {
          str = k.toStringAsFixed(1);
        }
        if (str.endsWith('.0')) {
          str = '${k.toInt()}';
        }
        return (number: str, unit: 'K');
      } else {
        if (val == val.roundToDouble()) {
          final str = val.toInt().toString();
          return (number: str.length > 5 ? str.substring(0, 5) : str, unit: '');
        }
        final str = val.toStringAsFixed(1);
        return (
          number: str.length > 5 ? val.toInt().toString() : str,
          unit: '',
        );
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildTargetCard(
            valueParts: formatValueParts(
              targets['month_target']?.toString() ?? '0',
            ),
            label: 'Monthly\nTarget',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            valueParts: formatValueParts(
              targets['total_sales']?.toString() ?? '0',
            ),
            label: 'Total\nSales',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            valueParts: formatValueParts(
              targets['today_sales']?.toString() ?? '0',
            ),
            label: 'Today\nSales',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildTargetCard(
            valueParts: formatValueParts(
              targets['no_of_orders']?.toString() ?? '0',
            ),
            label: 'No. of\nOrders',
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCard({
    required ({String number, String unit}) valueParts,
    required String label,
  }) {
    final valueColor = ThemeManager.instance.getTargetCardValueColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
      decoration: BoxDecoration(
        gradient: ThemeManager.instance.getTargetCardGradient(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: valueParts.number,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                if (valueParts.unit.isNotEmpty)
                  TextSpan(
                    text: valueParts.unit,
                    style: TextStyle(
                      color: valueColor.withValues(alpha: 0.85),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeManager.instance.getTargetCardLabelColor(),
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
  Widget _buildGoogleMapCard(BuildContext context) {
    return Consumer<LocationManager>(
      builder: (context, locManager, child) {
        final pos = locManager.currentPosition;
        if (pos == null) {
          return Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ThemeManager.instance.isLightMode
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFF121318).withValues(alpha: 0.8),
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
                        color: ThemeManager.instance.getTextSecondary(),
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
            child: _DashboardGoogleMap(position: pos),
          ),
        );
      },
    );
  }

  // ==========================================
  // FLOATING "+" PLACE ORDER BUTTON
  // ==========================================
  Widget _buildPlaceOrderFAB(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => _navigateToPlaceOrder(context),
        customBorder: const CircleBorder(),
        child: Ink(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ThemeManager.instance.getPlaceOrderGradient(),
            border: Border.all(
              color: ThemeManager.instance.getPlaceOrderBorderColor(),
              width: 3,
            ),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // ==========================================
  // ACTIVITY CARD
  // ==========================================
  Widget _buildActivityCard({
    String? title,
    String? subtitle,
    String? time,
    IconData? icon,
    Color? iconColor,
  }) {
    final bool isEmpty = title == null || title.isEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      height: 60,
      decoration: BoxDecoration(
        color: ThemeManager.instance.isLightMode
            ? const Color.fromARGB(20, 0, 43, 71)
            : const Color.fromARGB(20, 164, 219, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isEmpty
          ? const SizedBox.shrink()
          : Row(
              children: [
                if (icon != null && iconColor != null) ...[
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
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: ThemeManager.instance.getTextPrimary(),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: ThemeManager.instance.getTextSecondary(),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (time != null && time.isNotEmpty)
                  Text(
                    time,
                    style: TextStyle(
                      color: ThemeManager.instance.getTextTertiary(),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
    );
  }
}
