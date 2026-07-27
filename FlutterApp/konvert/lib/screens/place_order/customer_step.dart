import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';
import '../../managers/theme_manager.dart';
import '../../managers/location_manager.dart';

class CustomerStep extends StatefulWidget {
  const CustomerStep({super.key});

  @override
  State<CustomerStep> createState() => _CustomerStepState();
}

class _CustomerStepState extends State<CustomerStep> {
  @override
  void initState() {
    super.initState();
    LocationManager.instance.startLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    final theme = ThemeManager.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Category Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlaceOrderComponents.buildSearchBar(
                controller: state.customerSearchController,
                onChanged: state.filterCustomers,
                hint: 'Search Customer Name, Address...',
                onClear: () => state.filterCustomers(''),
                enabled: !state.isRefreshingCustomers,
              ),
              const SizedBox(height: 12),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PlaceOrderComponents.buildFilterChip(
                      label: 'All (${state.allCustomers.length})',
                      isSelected: state.selectedCustomerTypeFilter == 'all',
                      onTap: () => state.filterCustomersByType('all'),
                    ),
                    const SizedBox(width: 8),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Chemists',
                      icon: Icons.storefront_outlined,
                      isSelected: state.selectedCustomerTypeFilter == 'chemist',
                      onTap: () => state.filterCustomersByType('chemist'),
                    ),
                    const SizedBox(width: 8),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Doctors',
                      icon: Icons.medical_services_outlined,
                      isSelected: state.selectedCustomerTypeFilter == 'doctor',
                      onTap: () => state.filterCustomersByType('doctor'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Customer List (Listens to LocationManager for dynamic sorting & geofence distance updates)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.refreshCustomers(),
            color: theme.getAccentBlue(),
            child: IgnorePointer(
              ignoring: state.isRefreshingCustomers,
              child: Opacity(
                opacity: state.isRefreshingCustomers ? 0.5 : 1.0,
                child: state.filteredCustomers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 250,
                            child: PlaceOrderComponents.buildEmptyState(
                              'No Customers found',
                            ),
                          ),
                        ],
                      )
                    : ListenableBuilder(
                        listenable: LocationManager.instance,
                        builder: (context, _) {
                          // Sort customers: Enabled customers on top (sorted by name), Disabled customers below (sorted by name)
                          final displayCustomers = List<Map<String, dynamic>>.from(state.filteredCustomers);

                          displayCustomers.sort((a, b) {
                            final coordsA = LocationManager.instance.parseCustomerCoordinates(a);
                            final coordsB = LocationManager.instance.parseCustomerCoordinates(b);

                            final isEnabledA = LocationManager.instance.isLocationInGeofence(coordsA['lat'], coordsA['lng']);
                            final isEnabledB = LocationManager.instance.isLocationInGeofence(coordsB['lat'], coordsB['lng']);

                            if (isEnabledA && !isEnabledB) return -1;
                            if (!isEnabledA && isEnabledB) return 1;

                            final nameA = (a['customer_name'] ?? '').toString().toLowerCase();
                            final nameB = (b['customer_name'] ?? '').toString().toLowerCase();
                            return nameA.compareTo(nameB);
                          });

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            itemCount: displayCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = displayCustomers[index];
                              final type = customer['customer_type']?.toString() ?? '';
                              final isDoctor =
                                  type.toLowerCase().contains('doctor') || type == '2';

                              final isLight = theme.isLightMode;
                              final cardBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
                              final cardBorder = isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A);
                              final circleBadgeBg = isLight ? const Color(0xFF3B82F6) : const Color(0xFF0055FF);

                              // Parse & Swap Inverted Lat & Lng coordinates automatically
                              final coords = LocationManager.instance.parseCustomerCoordinates(customer);
                              final custLat = coords['lat'];
                              final custLong = coords['lng'];

                              // Geofence Validation: enabled by default if coordinates missing or invalid (0.0)
                              final isGeofencedEnabled = LocationManager.instance.isLocationInGeofence(custLat, custLong);
                              final distanceMeters = LocationManager.instance.getDistanceTo(custLat, custLong);

                              // Format distance display (in km if >= 1000m, else m)
                              String formatDist(double? m) {
                                if (m == null) return '';
                                if (m >= 1000) {
                                  final km = m / 1000.0;
                                  return '${km < 10 ? km.toStringAsFixed(1) : km.round()}km';
                                }
                                return '${m.round()}m';
                              }

                              final formattedDistance = formatDist(distanceMeters);

                              return Opacity(
                                opacity: isGeofencedEnabled ? 1.0 : 0.55,
                                child: Material(
                                  color: Colors.transparent,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: isGeofencedEnabled ? cardBg : (isLight ? Colors.grey.shade200 : const Color(0xFF1A1F2C)),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isGeofencedEnabled ? cardBorder : (isLight ? Colors.grey.shade300 : const Color(0xFF2B3347)),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: state.isRefreshingCustomers
                                          ? null
                                          : () {
                                              if (!isGeofencedEnabled) {
                                                final radiusMeters = LocationManager.instance.geofenceRadius;
                                                final radiusText = formatDist(radiusMeters);
                                                final distText = formattedDistance.isNotEmpty ? '$formattedDistance away' : 'out of range';
                                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(Icons.location_off_rounded, color: Colors.white, size: 18),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            '${customer['customer_name']} is $distText (Limit: $radiusText).',
                                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: const Color(0xFFEF4444),
                                                    duration: const Duration(seconds: 2),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                );
                                                return;
                                              }
                                              state.selectCustomer(customer);
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        child: Row(
                                          children: [
                                            // Solid Blue Circle Badge with Icon Inside
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isGeofencedEnabled ? circleBadgeBg : Colors.grey.shade500,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isDoctor
                                                    ? Icons.medical_services_outlined
                                                    : Icons.storefront_outlined,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                            const SizedBox(width: 14),

                                            // Middle Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          customer['customer_name'] ?? '',
                                                          style: TextStyle(
                                                            color: isGeofencedEnabled ? theme.getTextPrimary() : theme.getTextSecondary(),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (distanceMeters != null && custLat != null && custLat != 0.0) ...[
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: isGeofencedEnabled
                                                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                                                : const Color(0xFFEF4444).withValues(alpha: 0.15),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            isGeofencedEnabled ? formattedDistance : 'Out of range ($formattedDistance)',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: isGeofencedEnabled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    customer['customer_address'] != null &&
                                                            customer['customer_address'].toString().isNotEmpty
                                                        ? customer['customer_address'].toString()
                                                        : (isDoctor ? 'Doctor' : 'Chemist'),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: theme.getTextSecondary(),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Right Icon (Lock if disabled, Chevron if enabled)
                                            Icon(
                                              isGeofencedEnabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                                              color: isGeofencedEnabled
                                                  ? (isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8))
                                                  : const Color(0xFFEF4444),
                                              size: isGeofencedEnabled ? 22 : 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
