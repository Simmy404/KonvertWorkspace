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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Search
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Select Territory / Brick',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 38,
                child: TextField(
                  controller: state.brickSearchController,
                  onChanged: state.filterBricks,
                  enabled: !state.isRefreshingBricks,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  decoration: PlaceOrderComponents.buildSearchDecoration(
                    'Search Bricks by Name...',
                    isDark,
                    () {
                      state.brickSearchController.clear();
                      state.filterBricks('');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of Bricks (Disabled during refresh)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.refreshBricks(),
            color: const Color(0xFF1E56E2),
            child: IgnorePointer(
              ignoring: state.isRefreshingBricks,
              child: Opacity(
                opacity: state.isRefreshingBricks ? 0.5 : 1.0,
                child: state.filteredBricks.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 250,
                            child: PlaceOrderComponents.buildEmptyState(
                              'No Bricks found',
                              isDark,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        itemCount: state.filteredBricks.length,
                        itemBuilder: (context, index) {
                          final brick = state.filteredBricks[index];
                          final brickId = brick['brick_id'].toString();
                          final customerCount = state.getCustomerCountForBrick(
                            brickId,
                          );
                          final isAllBricks = brickId == '0';

                          return Material(
                            color: Colors.transparent,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1B1D22)
                                    : const Color(0xFFF6F8FD),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: state.isRefreshingBricks
                                    ? null
                                    : () => state.selectBrick(brick),
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
                                          color: isAllBricks
                                              ? (isDark
                                                  ? const Color(0xFF1E358A)
                                                  : const Color(0xFFEAF2FF))
                                              : (isDark
                                                  ? const Color(0xFF162544)
                                                  : const Color(0xFFF1F5F9)),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          isAllBricks
                                              ? Icons.apps_rounded
                                              : Icons.location_city_rounded,
                                          color: isAllBricks
                                              ? const Color(0xFF1E56E2)
                                              : (isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF475569)),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              brick['brick_name'] ?? '',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people_alt_outlined,
                                                  size: 12,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : const Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'} Available',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white54
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E56E2)
                                                  .withOpacity(0.2)
                                              : const Color(0xFF1E56E2)
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Select',
                                              style: TextStyle(
                                                color: isDark
                                                    ? const Color(0xFF83ABED)
                                                    : const Color(0xFF1E56E2),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: isDark
                                                  ? const Color(0xFF83ABED)
                                                  : const Color(0xFF1E56E2),
                                              size: 14,
                                            ),
                                          ],
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
