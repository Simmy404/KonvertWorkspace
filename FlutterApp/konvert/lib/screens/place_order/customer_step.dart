import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';
import '../../managers/theme_manager.dart';

class CustomerStep extends StatelessWidget {
  const CustomerStep({super.key});

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

        // Customer List
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
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        itemCount: state.filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = state.filteredCustomers[index];
                          final type = customer['customer_type']?.toString() ?? '';
                          final isDoctor =
                              type.toLowerCase().contains('doctor') || type == '2';

                          // Soft Pastel Colors
                          final doctorBg = theme.isLightMode
                              ? const Color(0xFFF3E8FF) // Soft pastel lavender
                              : const Color(0xFF2C1338);
                          final doctorIconColor = theme.isLightMode
                              ? const Color(0xFF8B5CF6) // Soft violet
                              : const Color(0xFFA855F7);

                          final chemistBg = theme.isLightMode
                              ? const Color(0xFFDCFCE7) // Soft pastel mint/green
                              : const Color(0xFF0F2D24);
                          final chemistIconColor = theme.isLightMode
                              ? const Color(0xFF16A34A) // Soft pastel emerald
                              : const Color(0xFF22C55E);

                          final isLight = theme.isLightMode;
                          final cardBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
                          final cardBorder = isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A);
                          final circleBadgeBg = isLight ? const Color(0xFF3B82F6) : const Color(0xFF0055FF);

                          return Material(
                            color: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: cardBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: state.isRefreshingCustomers
                                    ? null
                                    : () => state.selectCustomer(customer),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Solid Blue Circle Badge with Icon Inside
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: circleBadgeBg,
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
                                            Text(
                                              customer['customer_name'] ?? '',
                                              style: TextStyle(
                                                color: theme.getTextPrimary(),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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

                                      // Right Chevron Icon
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
