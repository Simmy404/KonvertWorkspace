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
        body: Stack(
          children: [
            // Main BG image matching the rest of the app
            Positioned.fill(
              child: Image.asset(
                ThemeManager.instance.getMainBG(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(
                      color: ThemeManager.instance.getAppBackgroundColor(),
                    ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top Compact App Bar & Step Indicator Header
                  _buildHeader(context, state),

                  // Main Content Area
                  Expanded(
                    child: state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: ThemeManager.instance.getAccentBlue(),
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
          ],
        ),
      ),
    );
  }

  Future<bool> _showDiscardConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: ThemeManager.instance.getSurfaceColor(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Discard Order?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeManager.instance.getTextPrimary(),
              ),
            ),
            content: Text(
              'You have selected products in your order. Going back will discard your order. Are you sure you want to proceed?',
              style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
    final theme = ThemeManager.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        border: Border(
          bottom: BorderSide(
            color: theme.getBorderColor(),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Bar
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (state.currentStep > 0 && !isEditing) {
                    state.goBack();
                    return;
                  }
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
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.getSurfaceColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.getTextPrimary(),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Edit Order #${state.editingInvoiceNumber}'
                          : 'Place New Order',
                      style: TextStyle(
                        color: theme.getTextPrimary(),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.selectedBrick != null ||
                        state.selectedCustomer != null)
                      Text(
                        '${state.selectedBrick != null ? state.selectedBrick!['brick_name'] : ''}${state.selectedCustomer != null ? ' › ${state.selectedCustomer!['customer_name']}' : ''}',
                        style: TextStyle(
                          color: theme.getAccentBlue(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive 3-Step Icon Bar with Labels
          Row(
            children: [
              _buildStepNode(
                icon: Icons.location_city_rounded,
                label: 'Area',
                isActive: state.currentStep == 0,
                isCompleted: state.currentStep > 0,
                onTap: () => state.jumpToStep(0),
              ),
              _buildStepDivider(state.currentStep > 0),
              _buildStepNode(
                icon: Icons.people_alt_rounded,
                label: 'Customer',
                isActive: state.currentStep == 1,
                isCompleted: state.currentStep > 1,
                onTap: () => state.jumpToStep(1),
              ),
              _buildStepDivider(state.currentStep > 1),
              _buildStepNode(
                icon: Icons.shopping_bag_rounded,
                label: 'Products',
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isCompleted
              ? ThemeManager.instance.getAccentBlue()
              : ThemeManager.instance.getBorderColor(),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildStepNode({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final canTap = isActive || isCompleted;
    final theme = ThemeManager.instance;
    final color = isActive
        ? theme.getAccentBlue()
        : isCompleted
            ? theme.getAccentBlue()
            : theme.getTextTertiary();

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.getAccentBlue().withOpacity(theme.isLightMode ? 0.12 : 0.25)
                  : isCompleted
                      ? theme.getAccentBlue().withOpacity(0.08)
                      : Colors.transparent,
              border: Border.all(
                color: isActive || isCompleted
                    ? theme.getAccentBlue().withOpacity(0.4)
                    : theme.getBorderColor(),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(
              isCompleted && !isActive ? Icons.check_rounded : icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? theme.getAccentBlue() : theme.getTextTertiary(),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
