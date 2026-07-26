import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_data.dart';
import 'place_order/place_order_state.dart';
import 'place_order/brick_step.dart';
import 'place_order/customer_step.dart';
import 'place_order/product_step.dart';
import '../managers/theme_manager.dart';

class PlaceOrderScreen extends StatelessWidget {
  final List<BookingData>? existingInvoiceItems;

  const PlaceOrderScreen({super.key, this.existingInvoiceItems});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PlaceOrderState(existingInvoiceItems: existingInvoiceItems),
      child: const _PlaceOrderView(),
    );
  }
}

class _PlaceOrderView extends StatelessWidget {
  const _PlaceOrderView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    return PopScope(

      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // If we are just navigating back to a previous step (and not editing), just go back.
        if (state.currentStep > 0 && state.editingInvoiceNumber == null) {
          state.goBack();
          return;
        }

        // If we are exiting the screen completely and there are items in the cart, confirm.
        if (state.cart.isNotEmpty) {
          final shouldDiscard = await _showDiscardConfirmationDialog(context);
          if (shouldDiscard && context.mounted) {
            state.cart.clear();
            Navigator.pop(context);
          }
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: ThemeManager.instance.getAppBackgroundColor(),
        body: SafeArea(
          child: Column(
            children: [
              // Top Compact App Bar & Step Indicator Header
              _buildHeader(context, state),

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
      ),
    );
  }

  Future<bool> _showDiscardConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Discard Order?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'You have selected products in your order. Going back will discard your order. Are you sure you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ==========================================
  // TOP COMPACT HEADER & INTERACTIVE BREADCRUMBS
  // ==========================================
  Widget _buildHeader(
    BuildContext context,
    PlaceOrderState state,
  ) {
    final isEditing = state.editingInvoiceNumber != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: ThemeManager.instance.getContainerColor(),
        border: Border(
          bottom: BorderSide(
            color: ThemeManager.instance.getBorderColor(),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeManager.instance.isLightMode
                ? const Color(0xFF003087).withOpacity(0.04)
                : Colors.black.withOpacity(0.3),
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
                onPressed: () async {
                  // If we are just navigating back to a previous step (and not editing), just go back.
                  if (state.currentStep > 0 && !isEditing) {
                    state.goBack();
                    return;
                  }

                  // If we are exiting the screen completely and there are items in the cart, confirm.
                  if (state.cart.isNotEmpty) {
                    final shouldDiscard = await _showDiscardConfirmationDialog(context);
                    if (shouldDiscard && context.mounted) {
                      state.cart.clear();
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ThemeManager.instance.getTextPrimary(),
                  size: 16,
                ),
              ),

              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Edit Order #${state.editingInvoiceNumber}'
                          : 'Place New Order',
                      style: TextStyle(
                        color: ThemeManager.instance.getTextPrimary(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.selectedBrick != null ||
                        state.selectedCustomer != null)
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

          // Interactive 3-Step Icon Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIcon(
                iconData: Icons.location_city_rounded,
                isActive: state.currentStep == 0,
                isCompleted: state.currentStep > 0,
                onTap: () => state.jumpToStep(0),
              ),
              _buildStepDivider(state.currentStep > 0),
              _buildStepIcon(
                iconData: Icons.people_alt_rounded,
                isActive: state.currentStep == 1,
                isCompleted: state.currentStep > 1,
                onTap: () => state.jumpToStep(1),
              ),
              _buildStepDivider(state.currentStep > 1),
              _buildStepIcon(
                iconData: Icons.shopping_bag_rounded,
                isActive: state.currentStep == 2,
                isCompleted: false,
                onTap: () => state.jumpToStep(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted
            ? ThemeManager.instance.getAccentBlue()
            : ThemeManager.instance.getBorderColor(),
      ),
    );
  }

  Widget _buildStepIcon({
    required IconData iconData,
    required bool isActive,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final canTap = isActive || isCompleted;
    final color = isActive
        ? ThemeManager.instance.getAccentBlue()
        : isCompleted
        ? (ThemeManager.instance.isLightMode ? ThemeManager.instance.getAccentBlue() : ThemeManager.instance.getTextSecondary())
        : ThemeManager.instance.getTextTertiary();

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? ThemeManager.instance.getAccentBlue().withOpacity(ThemeManager.instance.isLightMode ? 0.1 : 0.2)
              : Colors.transparent,
        ),
        child: Icon(iconData, size: 24, color: color),
      ),
    );
  }
}
