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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: state.customerSearchController,
              onChanged: state.filterCustomers,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
              ),
              decoration: PlaceOrderComponents.buildSearchDecoration(
                'Search Customers...',
                isDark,
                () {
                  state.customerSearchController.clear();
                  state.filterCustomers('');
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: state.filteredCustomers.isEmpty
              ? PlaceOrderComponents.buildEmptyState('No Customers found for this Brick', isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  itemCount: state.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = state.filteredCustomers[index];
                    final type = customer['customer_type']?.toString() ?? '';
                    final isDoctor =
                        type.toLowerCase().contains('doctor') || type == '2';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121318) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF22242E)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDoctor
                                ? (isDark
                                      ? const Color(0xFF2C1338)
                                      : const Color(0xFFF3E8FF))
                                : (isDark
                                      ? const Color(0xFF0F2D24)
                                      : const Color(0xFFDCFCE7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isDoctor
                                ? Icons.medical_services_outlined
                                : Icons.storefront_outlined,
                            color: isDoctor
                                ? const Color(0xFFA855F7)
                                : const Color(0xFF16A34A),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          customer['customer_name'] ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          '${type.isNotEmpty ? type : 'Chemist'}${customer['customer_address'] != null && customer['customer_address'].toString().isNotEmpty ? ' • ${customer['customer_address']}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                        onTap: () => state.selectCustomer(customer),
                      ),
                    );
                  },
                ),
        ),

        // Persistent Location Map Card pinned below the customer list
        PlaceOrderComponents.buildLocationMapCard(state, isDark),
      ],
    );
  }
}
