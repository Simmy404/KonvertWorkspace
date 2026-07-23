import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';

class BrickStep extends StatelessWidget {
  const BrickStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: state.brickSearchController,
              onChanged: state.filterBricks,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
              ),
              decoration: PlaceOrderComponents.buildSearchDecoration(
                'Search Bricks...',
                isDark,
                () {
                  state.brickSearchController.clear();
                  state.filterBricks('');
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: state.filteredBricks.isEmpty
              ? PlaceOrderComponents.buildEmptyState('No Bricks found', isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  itemCount: state.filteredBricks.length,
                  itemBuilder: (context, index) {
                    final brick = state.filteredBricks[index];
                    final brickId = brick['brick_id'].toString();
                    final customerCount = state.getCustomerCountForBrick(
                      brickId,
                    );

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
                            color: isDark
                                ? const Color(0xFF1E358A)
                                : const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            brickId == '0'
                                ? Icons.apps_rounded
                                : Icons.location_city_rounded,
                            color: const Color(0xFF1E56E2),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          brick['brick_name'] ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 11,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                        onTap: () => state.selectBrick(brick),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
