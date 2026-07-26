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

                          return Material(
                            color: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: theme.getListItemColor(),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.getBorderColor(),
                                  width: 1.2,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: state.isRefreshingCustomers
                                    ? null
                                    : () => state.selectCustomer(customer),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDoctor ? doctorBg : chemistBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isDoctor
                                              ? Icons.medical_services_outlined
                                              : Icons.storefront_outlined,
                                          color: isDoctor ? doctorIconColor : chemistIconColor,
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
                                                      color: theme.getTextPrimary(),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isDoctor ? doctorBg : chemistBg,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    isDoctor ? 'Doctor' : 'Chemist',
                                                    style: TextStyle(
                                                      color: isDoctor ? doctorIconColor : chemistIconColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              customer['customer_address'] != null &&
                                                      customer['customer_address'].toString().isNotEmpty
                                                  ? customer['customer_address'].toString()
                                                  : 'No address provided',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: theme.getTextSecondary(),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: theme.getAccentBlue().withOpacity(theme.isLightMode ? 0.08 : 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: theme.isLightMode ? theme.getAccentBlue() : const Color(0xFF83ABED),
                                          size: 16,
                                        ),
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
