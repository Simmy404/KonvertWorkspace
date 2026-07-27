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
    final titleColor = theme.isLightMode ? const Color(0xFF0022FF) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Title Bar matching mockup
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: titleColor,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  isEditing
                      ? 'Edit Order #${state.editingInvoiceNumber}'
                      : 'Place Order',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-Step Circle Node Bar with Dots & Icons inside Circles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepCircleNode(
                  icon: Icons.location_city_rounded,
                  stepIndex: 0,
                  currentStep: state.currentStep,
                  onTap: () => state.jumpToStep(0),
                  theme: theme,
                ),
                _buildStepDotsDivider(isCompleted: state.currentStep > 0, theme: theme),
                _buildStepCircleNode(
                  icon: Icons.person_rounded,
                  stepIndex: 1,
                  currentStep: state.currentStep,
                  onTap: () => state.jumpToStep(1),
                  theme: theme,
                ),
                _buildStepDotsDivider(isCompleted: state.currentStep > 1, theme: theme),
                _buildStepCircleNode(
                  icon: Icons.shopping_bag_rounded,
                  stepIndex: 2,
                  currentStep: state.currentStep,
                  onTap: () => state.jumpToStep(2),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDotsDivider({required bool isCompleted, required ThemeManager theme}) {
    final activeDotColor = const Color(0xFFFF9D54);
    final inactiveDotColor = theme.isLightMode
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF3B4254);
    final dotColor = isCompleted ? activeDotColor : inactiveDotColor;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) {
          return Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircleNode({
    required IconData icon,
    required int stepIndex,
    required int currentStep,
    required VoidCallback onTap,
    required ThemeManager theme,
  }) {
    final isActive = currentStep == stepIndex;
    final isCompleted = currentStep > stepIndex;
    final canTap = isActive || isCompleted;

    // Node Colors matching mockup images
    final activeBgColor = const Color(0xFFFF9D54); // Vibrant orange/amber
    final inactiveBgColor = theme.isLightMode
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF3B4254);

    final bgColor = (isActive || isCompleted) ? activeBgColor : inactiveBgColor;
    final iconColor = (isActive || isCompleted) ? Colors.white : Colors.white70;

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeBgColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}
