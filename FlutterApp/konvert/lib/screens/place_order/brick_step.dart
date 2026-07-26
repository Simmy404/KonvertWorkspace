import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';
import '../../managers/theme_manager.dart';

class BrickStep extends StatelessWidget {
  const BrickStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    final theme = ThemeManager.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: PlaceOrderComponents.buildSearchBar(
            controller: state.brickSearchController,
            onChanged: state.filterBricks,
            hint: 'Search ${state.allBricks.length} Bricks',
            onClear: () => state.filterBricks(''),
            enabled: !state.isRefreshingBricks,
          ),
        ),

        // List of Bricks
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.refreshBricks(),
            color: theme.getAccentBlue(),
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
                                onTap: state.isRefreshingBricks
                                    ? null
                                    : () => state.selectBrick(brick),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isAllBricks
                                              ? theme.getAccentBlue().withOpacity(theme.isLightMode ? 0.1 : 0.2)
                                              : theme.getSurfaceColor(),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isAllBricks
                                              ? Icons.apps_rounded
                                              : Icons.location_city_rounded,
                                          color: isAllBricks
                                              ? theme.getAccentBlue()
                                              : theme.getTextSecondary(),
                                          size: 20,
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
                                                color: theme.getTextPrimary(),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people_alt_outlined,
                                                  size: 14,
                                                  color: theme.getTextSecondary(),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'}',
                                                  style: TextStyle(
                                                    color: theme.getTextSecondary(),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: theme.getAccentBlue().withOpacity(
                                            theme.isLightMode ? 0.08 : 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: theme.isLightMode
                                              ? theme.getAccentBlue()
                                              : const Color(0xFF83ABED),
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
