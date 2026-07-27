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
                                onTap: state.isRefreshingBricks
                                    ? null
                                    : () => state.selectBrick(brick),
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
                                          isAllBricks
                                              ? Icons.apps_rounded
                                              : Icons.location_city_rounded,
                                          color: Colors.white,
                                          size: 17,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Middle Title & Customer Count
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              brick['brick_name'] ?? '',
                                              style: TextStyle(
                                                color: theme.getTextPrimary(),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'}',
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
