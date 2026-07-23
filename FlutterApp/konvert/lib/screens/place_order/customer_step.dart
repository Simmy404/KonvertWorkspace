import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';

class CustomerStep extends StatelessWidget {
  const CustomerStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header, Search & Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Customer',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.selectedBrick != null)
                        Text(
                          '${state.selectedBrick!['brick_name']}',
                          style: const TextStyle(
                            color: Color(0xFF1E56E2),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: state.isRefreshingCustomers
                            ? null
                            : () => state.refreshCustomers(),
                        icon: state.isRefreshingCustomers
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
                        tooltip: 'Refresh Customers',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 38,
                child: TextField(
                  controller: state.customerSearchController,
                  onChanged: state.filterCustomers,
                  enabled: !state.isRefreshingCustomers,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  decoration: PlaceOrderComponents.buildSearchDecoration(
                    'Search Customer Name, Address...',
                    isDark,
                    () {
                      state.customerSearchController.clear();
                      state.filterCustomers('');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PlaceOrderComponents.buildFilterChip(
                      label: 'All Customers (${state.allCustomers.length})',
                      isSelected: state.selectedCustomerTypeFilter == 'all',
                      onTap: () => state.filterCustomersByType('all'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Chemists',
                      icon: Icons.storefront_outlined,
                      isSelected: state.selectedCustomerTypeFilter == 'chemist',
                      onTap: () => state.filterCustomersByType('chemist'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Doctors',
                      icon: Icons.medical_services_outlined,
                      isSelected: state.selectedCustomerTypeFilter == 'doctor',
                      onTap: () => state.filterCustomersByType('doctor'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Customer List (Disabled while refreshing)
        Expanded(
          child: IgnorePointer(
            ignoring: state.isRefreshingCustomers,
            child: Opacity(
              opacity: state.isRefreshingCustomers ? 0.5 : 1.0,
              child: state.filteredCustomers.isEmpty
                  ? PlaceOrderComponents.buildEmptyState('No Customers found', isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      itemCount: state.filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = state.filteredCustomers[index];
                        final type = customer['customer_type']?.toString() ?? '';
                        final isDoctor =
                            type.toLowerCase().contains('doctor') || type == '2';

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF121318) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF22242E)
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.2)
                                      : const Color(0xFF003087).withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: state.isRefreshingCustomers
                                  ? null
                                  : () => state.selectCustomer(customer),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDoctor
                                            ? (isDark
                                                ? const Color(0xFF2C1338)
                                                : const Color(0xFFF3E8FF))
                                            : (isDark
                                                ? const Color(0xFF0F2D24)
                                                : const Color(0xFFDCFCE7)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isDoctor
                                            ? Icons.medical_services_outlined
                                            : Icons.storefront_outlined,
                                        color: isDoctor
                                            ? const Color(0xFFA855F7)
                                            : const Color(0xFF16A34A),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(0xFF0F172A),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDoctor
                                                      ? (isDark
                                                          ? const Color(0xFF38154D)
                                                          : const Color(0xFFF3E8FF))
                                                      : (isDark
                                                          ? const Color(0xFF12382B)
                                                          : const Color(0xFFDCFCE7)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isDoctor ? 'Doctor' : 'Chemist',
                                                  style: TextStyle(
                                                    color: isDoctor
                                                        ? const Color(0xFFA855F7)
                                                        : const Color(0xFF16A34A),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            customer['customer_address'] != null &&
                                                    customer['customer_address'].toString().isNotEmpty
                                                ? customer['customer_address'].toString()
                                                : 'No address provided',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white54
                                                  : const Color(0xFF64748B),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF94A3B8),
                                      size: 18,
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

        // Persistent Location Map Card pinned below the customer list
        PlaceOrderComponents.buildLocationMapCard(state, isDark),
      ],
    );
  }
}
