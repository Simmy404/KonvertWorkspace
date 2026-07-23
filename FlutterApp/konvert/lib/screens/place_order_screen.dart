import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_data.dart';
import 'place_order/place_order_state.dart';
import 'place_order/brick_step.dart';
import 'place_order/customer_step.dart';
import 'place_order/product_step.dart';

class PlaceOrderScreen extends StatelessWidget {
  final List<BookingData>? existingInvoiceItems;

  const PlaceOrderScreen({super.key, this.existingInvoiceItems});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaceOrderState(existingInvoiceItems: existingInvoiceItems),
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
  // TOP COMPACT HEADER & INTERACTIVE BREADCRUMBS
  // ==========================================
  Widget _buildHeader(
    BuildContext context,
    PlaceOrderState state,
    bool isDark,
  ) {
    final isEditing = state.editingInvoiceNumber != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1437) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1E2D68).withOpacity(0.5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF003087).withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                  if (state.currentStep > 0 && !isEditing) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Order #${state.editingInvoiceNumber}' : 'Place New Order',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.selectedBrick != null || state.selectedCustomer != null)
                      Text(
                        '${state.selectedBrick != null ? state.selectedBrick!['brick_name'] : ''}${state.selectedCustomer != null ? ' › ${state.selectedCustomer!['customer_name']}' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF1E56E2),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Interactive 3-Step Pill Bar
          Row(
            children: [
              _buildStepPill(
                label: '1. Bricks',
                isActive: state.currentStep == 0,
                isCompleted: state.currentStep > 0,
                onTap: () => state.jumpToStep(0),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                label: '2. Customers',
                isActive: state.currentStep == 1,
                isCompleted: state.currentStep > 1,
                onTap: () => state.jumpToStep(1),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildStepPill(
                label: '3. Products',
                isActive: state.currentStep == 2,
                isCompleted: false,
                onTap: () => state.jumpToStep(2),
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
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final canTap = isActive || isCompleted;

    return Expanded(
      child: GestureDetector(
        onTap: canTap ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1E56E2)
                : isCompleted
                ? (isDark ? const Color(0xFF1E2D68) : const Color(0xFFD6E6FF))
                : (isDark ? const Color(0xFF121318) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF1E56E2).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                const Padding(
                  padding: EdgeInsets.only(right: 3.0),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 12,
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
      ),
    );
  }
}
