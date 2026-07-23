import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'place_order/place_order_state.dart';
import 'place_order/brick_step.dart';
import 'place_order/customer_step.dart';
import 'place_order/product_step.dart';

class PlaceOrderScreen extends StatelessWidget {
  const PlaceOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaceOrderState(),
      child: const _PlaceOrderView(),
    );
  }
}

class _PlaceOrderView extends StatelessWidget {
  const _PlaceOrderView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<PlaceOrderState>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF030305)
          : const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Compact App Bar & Step Indicator Header
            _buildHeader(context, state, isDark),

            // Main Content Area
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E56E2),
                        strokeWidth: 2.5,
                      ),
                    )
                  : IndexedStack(
                      index: state.currentStep,
                      children: const [
                        BrickStep(),
                        CustomerStep(),
                        ProductStep(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP COMPACT HEADER & STEP INDICATOR
  // ==========================================
  Widget _buildHeader(
    BuildContext context,
    PlaceOrderState state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1437) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1E2D68).withOpacity(0.5)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Bar
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  if (state.currentStep > 0) {
                    state.goBack();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Place Order',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.selectedCustomer != null &&
                        state.currentStep == 2)
                      Expanded(
                        child: Text(
                          ' • ${state.selectedCustomer!['customer_name']}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else if (state.selectedBrick != null &&
                        state.currentStep == 1)
                      Expanded(
                        child: Text(
                          ' • ${state.selectedBrick!['brick_name']}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Compact 3-Step Pill Bar
          Row(
            children: [
              _buildStepPill(
                label: '1. Bricks',
                isActive: state.currentStep == 0,
                isCompleted: state.currentStep > 0,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                label: '2. Customers',
                isActive: state.currentStep == 1,
                isCompleted: state.currentStep > 1,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                label: '3. Products',
                isActive: state.currentStep == 2,
                isCompleted: false,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required String label,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF1E56E2)
              : isCompleted
              ? (isDark ? const Color(0xFF1E2D68) : const Color(0xFFD6E6FF))
              : (isDark ? const Color(0xFF121318) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.only(right: 3.0),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 11,
                  color: Color(0xFF1E56E2),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : isCompleted
                    ? (isDark ? Colors.white70 : const Color(0xFF1E56E2))
                    : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                fontSize: 10,
                fontWeight: isActive || isCompleted
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
