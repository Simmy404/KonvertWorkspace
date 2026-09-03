import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_order_product.dart';
import '../../models/customer_last_booking.dart';
import '../../services/api_service.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';
import '../../managers/theme_manager.dart';

class ProductStep extends StatelessWidget {
  const ProductStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();

    final theme = ThemeManager.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header, Search Box & Category Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PlaceOrderComponents.buildSearchBar(
                      controller: state.productSearchController,
                      onChanged: state.filterProducts,
                      hint: 'Search ${state.allProducts.length} Products',
                      onClear: () => state.filterProducts(''),
                      enabled: !state.isRefreshingProducts,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Last Booking Dialog Button
                  _buildLastBookingButton(context, state, theme),
                ],
              ),
              const SizedBox(height: 12),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PlaceOrderComponents.buildFilterChip(
                      label: 'All (${state.allProducts.length})',
                      isSelected: state.selectedProductCategoryFilter == 'all',
                      onTap: () => state.filterProductsByCategory('all'),
                    ),
                    const SizedBox(width: 8),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Rx (Prescription)',
                      icon: Icons.medication_outlined,
                      isSelected: state.selectedProductCategoryFilter == 'rx',
                      onTap: () => state.filterProductsByCategory('rx'),
                    ),
                    const SizedBox(width: 8),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'OTC',
                      icon: Icons.local_pharmacy_outlined,
                      isSelected: state.selectedProductCategoryFilter == 'otc',
                      onTap: () => state.filterProductsByCategory('otc'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Products List (Disabled while refreshing)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.refreshProducts(),
            color: theme.getAccentBlue(),
            child: IgnorePointer(
              ignoring: state.isRefreshingProducts,
              child: Opacity(
                opacity: state.isRefreshingProducts ? 0.5 : 1.0,
                child: state.filteredProducts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 250,
                            child: PlaceOrderComponents.buildEmptyState(
                              'No Products found',
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
                        itemCount: state.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = state.filteredProducts[index];
                          final prodId = product['product_id'].toString();

                          final cartItem = state.cart
                              .where((p) => p.prodID == prodId)
                              .firstOrNull;

                          final isOtc =
                              product['product_is_otc'] != null &&
                              product['product_is_otc']
                                  .toString()
                                  .trim()
                                  .isNotEmpty;

                          final isLight = theme.isLightMode;
                          final cardBg = isLight
                              ? const Color(0xFFEFF4FD)
                              : const Color(0xFF121624);
                          final cardBorder = isLight
                              ? const Color(0xFFE2ECFC)
                              : const Color(0xFF1E253A);
                          final circleBadgeBg = isLight
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF0055FF);

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: cartItem != null
                                  ? theme.getAccentBlue().withOpacity(
                                      isLight ? 0.08 : 0.2,
                                    )
                                  : cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cartItem != null
                                    ? theme.getAccentBlue()
                                    : cardBorder,
                                width: 1.0,
                              ),
                            ),
                            child: InkWell(
                              onTap: state.isRefreshingProducts
                                  ? null
                                  : () => _showProductPricingBottomSheet(
                                      context,
                                      state,
                                      product,
                                      cartItem,
                                      autofocusFirstInput: cartItem == null,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Solid Blue Circle Badge with Icon Inside
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: circleBadgeBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.medication_outlined,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Product Title & Price Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product['product_name'] ?? '',
                                                  style: TextStyle(
                                                    color: theme
                                                        .getTextPrimary(),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isOtc) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFFEF3C7,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'OTC',
                                                    style: TextStyle(
                                                      color: Color(0xFFD97706),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                'TP: Rs ${product['product_tp'] ?? '0'}',
                                                style: TextStyle(
                                                  color: theme
                                                      .getTextSecondary(),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (cartItem != null &&
                                                  (cartItem.discount > 0 ||
                                                      cartItem.bonus > 0)) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '(${cartItem.discount > 0 ? '${cartItem.discount}% Off' : ''}${cartItem.discount > 0 && cartItem.bonus > 0 ? ' + ' : ''}${cartItem.bonus > 0 ? '+Rs ${cartItem.bonus}' : ''})',
                                                  style: const TextStyle(
                                                    color: Color(0xFF16A34A),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Inline Quantity Stepper / Add Button
                                    cartItem != null
                                        ? _buildQtyStepper(
                                            context,
                                            state,
                                            prodId,
                                            cartItem,
                                            theme,
                                          )
                                        : _buildAddButton(theme),
                                  ],
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

        // Modern Floating Bottom Cart Bar
        IgnorePointer(
          ignoring: state.isRefreshingProducts,
          child: Opacity(
            opacity: state.isRefreshingProducts ? 0.5 : 1.0,
            child: _buildBottomCartSummary(context, state),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FLOATING BOTTOM CART SUMMARY BAR
  // ==========================================
  Widget _buildBottomCartSummary(BuildContext context, PlaceOrderState state) {
    final theme = ThemeManager.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: theme.getBorderColor())),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Items Count & Grand Total
            GestureDetector(
              onTap: () => _showCartDetailsModal(context, state),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: theme.getAccentBlue(),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.cart.length} ${state.cart.length == 1 ? 'Item' : 'Items'} in Cart',
                        style: TextStyle(
                          color: theme.getTextSecondary(),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 16,
                        color: theme.getAccentBlue(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: Rs ${state.cartGrandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.getTextPrimary(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Primary Action Button
            ElevatedButton.icon(
              onPressed: () => _showCartDetailsModal(context, state),
              icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
              label: Text(
                state.editingInvoiceNumber != null
                    ? 'Update Order'
                    : 'Review & Save',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.getAccentBlue(),
                disabledBackgroundColor: theme.isLightMode
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ==========================================
  // QTY STEPPER HELPERS
  // ==========================================

  /// Inline −/qty/+ stepper. Long-press on the qty number to type directly.
  Widget _buildQtyStepper(
    BuildContext context,
    PlaceOrderState state,
    String prodId,
    dynamic cartItem,
    ThemeManager theme,
  ) {
    return GestureDetector(
      // Long-press on the whole stepper → quick-type qty dialog
      onLongPress: state.isRefreshingProducts
          ? null
          : () => _showQuickQtyDialog(
              context,
              state,
              prodId,
              cartItem.qty,
              theme,
            ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.getSurfaceColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.getBorderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: state.isRefreshingProducts
                  ? null
                  : () => state.decrementProductQty(prodId),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  cartItem.qty == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  size: 17,
                  color: cartItem.qty == 1
                      ? const Color(0xFFEF4444)
                      : theme.getTextPrimary(),
                ),
              ),
            ),
            // Qty number — long-press to type
            GestureDetector(
              onLongPress: state.isRefreshingProducts
                  ? null
                  : () => _showQuickQtyDialog(
                      context,
                      state,
                      prodId,
                      cartItem.qty,
                      theme,
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${cartItem.qty}',
                  style: TextStyle(
                    color: theme.getTextPrimary(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: state.isRefreshingProducts
                  ? null
                  : () => state.incrementProductQty({
                      'product_id': prodId,
                      'product_name': cartItem.name,
                      'product_tp': cartItem.price.toString(),
                    }),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_rounded,
                  size: 17,
                  color: theme.getAccentBlue(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Large solid-blue pill "Add" button for products not yet in cart.
  Widget _buildAddButton(ThemeManager theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.getAccentBlue(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Add',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick-type dialog: lets the salesman type a qty directly without tapping + many times.
  void _showQuickQtyDialog(
    BuildContext context,
    PlaceOrderState state,
    String prodId,
    int currentQty,
    ThemeManager theme,
  ) {
    final ctrl = TextEditingController(text: currentQty.toString())
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: currentQty.toString().length,
      );

    void setQtyAndPop(BuildContext ctx) {
      final newQty = int.tryParse(ctrl.text.trim()) ?? 0;
      if (newQty > 0) {
        final existing = state.cart.firstWhere(
          (p) => p.prodID == prodId,
          orElse: () => throw Exception(),
        );
        state.addToCart(existing.copyWith(qty: newQty));
      } else if (newQty == 0) {
        state.removeFromCart(prodId);
      }
      Navigator.pop(ctx);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.getContainerColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Set Quantity',
          style: TextStyle(
            color: theme.getTextPrimary(),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          style: TextStyle(
            color: theme.getTextPrimary(),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.getAccentBlue(), width: 2),
            ),
          ),
          onSubmitted: (_) => setQtyAndPop(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.getTextSecondary()),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.getAccentBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => setQtyAndPop(ctx),
            child: const Text(
              'Set',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EXPANDABLE CART DETAILS MODAL BOTTOM SHEET
  // ==========================================
  void _showCartDetailsModal(BuildContext context, PlaceOrderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: ThemeManager.instance.getAppBackgroundColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle indicator bar
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeManager.instance.getDividerColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Summary (${state.cart.length} items)',
                          style: TextStyle(
                            color: ThemeManager.instance.getTextPrimary(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: ThemeManager.instance.getTextSecondary(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Cart Items List
                  Expanded(
                    child: state.cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 48,
                                  color: ThemeManager.instance.getAccentBlue(),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Zero Order Visit Confirmation',
                                  style: TextStyle(
                                    color: ThemeManager.instance
                                        .getTextPrimary(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No products added. Tap confirm below to record visit.',
                                  style: TextStyle(
                                    color: ThemeManager.instance
                                        .getTextSecondary(),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.cart.length,
                            itemBuilder: (context, index) {
                              final item = state.cart[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ThemeManager.instance
                                      .getContainerColor(),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ThemeManager.instance
                                        .getBorderColor(),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              color: ThemeManager.instance
                                                  .getTextPrimary(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'TP: Rs ${item.price} | Qty: ${item.qty}${item.discount > 0 ? ' | Disc: ${item.discount}%' : ''}${item.bonus > 0 ? ' | Bonus: Rs ${item.bonus}' : ''}',
                                            style: TextStyle(
                                              color: ThemeManager.instance
                                                  .getTextSecondary(),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item.getGrandTotal().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: ThemeManager.instance
                                            .getTextPrimary(),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        state.removeFromCart(item.prodID);
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Remarks & Final Action Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeManager.instance.getSurfaceColor(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (val) => state.remarks = val,
                          controller: TextEditingController(text: state.remarks)
                            ..selection = TextSelection.collapsed(
                              offset: state.remarks.length,
                            ),
                          style: TextStyle(
                            color: ThemeManager.instance.getTextPrimary(),
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Order Remarks (Optional)...',
                            hintStyle: TextStyle(
                              color: ThemeManager.instance.getTextTertiary(),
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.note_alt_outlined,
                              size: 16,
                              color: ThemeManager.instance.getTextTertiary(),
                            ),
                            filled: true,
                            fillColor: ThemeManager.instance
                                .getContainerColor(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await state.confirmOrder();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.cart.isEmpty
                                          ? 'Visit Confirmed Successfully!'
                                          : 'Order Saved Successfully!',
                                    ),
                                    backgroundColor: const Color(0xFF16A34A),
                                  ),
                                );
                                Navigator.pop(context); // close bottom sheet
                                if (state.editingInvoiceNumber != null) {
                                  Navigator.pop(
                                    context,
                                    true,
                                  ); // close PlaceOrderScreen if editing
                                } else {
                                  state
                                      .resetOrderAndGoToBricks(); // take user to Bricks step for new order
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                            ),
                            label: Text(
                              state.cart.isEmpty
                                  ? 'Confirm Visit (No Order)'
                                  : (state.editingInvoiceNumber != null
                                        ? 'Save Changes'
                                        : 'Confirm & Save Order'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E56E2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ADVANCED PRODUCT PRICING BOTTOM SHEET
  // ==========================================
  void _showProductPricingBottomSheet(
    BuildContext context,
    PlaceOrderState state,
    Map<String, dynamic> product,
    PlaceOrderProduct? existingItem, {
    bool autofocusFirstInput = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductPricingDialogContent(
          state: state,
          product: product,
          existingItem: existingItem,
          autofocusFirstInput: autofocusFirstInput,
        );
      },
    );
  }

  Widget _buildLastBookingButton(
    BuildContext context,
    PlaceOrderState state,
    ThemeManager theme,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.getListItemColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.getBorderColor(), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showPreviousBookingDialog(context, state),
          child: const Center(
            child: Icon(
              Icons.history_rounded,
              color: Color(0xFFFF9D54),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  void _showPreviousBookingDialog(BuildContext context, PlaceOrderState state) {
    final customer = state.selectedCustomer;
    final customerId = customer?['customer_id']?.toString() ?? '';
    final customerName = customer?['customer_name']?.toString() ?? 'Customer';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _PreviousBookingDialog(
        customerId: customerId,
        customerName: customerName,
      ),
    );
  }
}

class _ProductPricingDialogContent extends StatefulWidget {
  final PlaceOrderState state;
  final Map<String, dynamic> product;
  final PlaceOrderProduct? existingItem;
  final bool autofocusFirstInput;

  const _ProductPricingDialogContent({
    Key? key,
    required this.state,
    required this.product,
    this.existingItem,
    this.autofocusFirstInput = true,
  }) : super(key: key);

  @override
  State<_ProductPricingDialogContent> createState() =>
      _ProductPricingDialogContentState();
}

class _ProductPricingDialogContentState
    extends State<_ProductPricingDialogContent> {
  late int qty;
  late double price;
  late double discount;
  late double bonus;

  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController discountController;
  late TextEditingController bonusController;

  late FocusNode qtyFocus;
  late FocusNode priceFocus;
  late FocusNode discountFocus;
  late FocusNode bonusFocus;

  @override
  void initState() {
    super.initState();
    qty = widget.existingItem?.qty ?? 1;
    price =
        widget.existingItem?.price ??
        double.tryParse(widget.product['product_tp'].toString()) ??
        0.0;
    discount = widget.existingItem?.discount ?? 0.0;
    bonus = widget.existingItem?.bonus ?? 0.0;

    qtyController = TextEditingController(text: qty.toString());
    priceController = TextEditingController(text: price.toString());
    discountController = TextEditingController(text: discount.toString());
    bonusController = TextEditingController(text: bonus.toString());

    // Initially select quantity text if autofocusing
    if (widget.autofocusFirstInput) {
      qtyController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: qtyController.text.length,
      );
    }

    qtyFocus = FocusNode();
    priceFocus = FocusNode();
    discountFocus = FocusNode();
    bonusFocus = FocusNode();

    // Select text when a field receives focus so user can quickly type over existing values
    _addSelectAllOnFocus(qtyFocus, qtyController);
    _addSelectAllOnFocus(priceFocus, priceController);
    _addSelectAllOnFocus(discountFocus, discountController);
    _addSelectAllOnFocus(bonusFocus, bonusController);
  }

  void _addSelectAllOnFocus(FocusNode node, TextEditingController controller) {
    node.addListener(() {
      if (node.hasFocus && controller.text.isNotEmpty) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    discountController.dispose();
    bonusController.dispose();
    qtyFocus.dispose();
    priceFocus.dispose();
    discountFocus.dispose();
    bonusFocus.dispose();
    super.dispose();
  }

  void _saveToCart() {
    if (qty > 0) {
      final item = PlaceOrderProduct(
        prodID: widget.product['product_id'].toString(),
        name: widget.product['product_name'].toString(),
        qty: qty,
        price: price,
        discount: discount,
        bonus: bonus,
      );
      widget.state.addToCart(item);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double total = (price * qty) - ((price * qty * discount) / 100) + bonus;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeManager.instance.getContainerColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.product['product_name'] ??
                        'Product Pricing & Details',
                    style: TextStyle(
                      color: ThemeManager.instance.getTextPrimary(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: ThemeManager.instance.getTextSecondary(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            PlaceOrderComponents.buildDialogInput(
              'Quantity',
              qtyController,
              (v) {
                setState(() {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed > 0) {
                    qty = parsed;
                  }
                });
              },
              autofocus: widget.autofocusFirstInput,
              focusNode: qtyFocus,
              nextFocusNode: priceFocus,
              textInputAction: TextInputAction.next,
            ),
            PlaceOrderComponents.buildDialogInput(
              'Unit Price (TP)',
              priceController,
              (v) => setState(() => price = double.tryParse(v) ?? 0.0),
              autofocus: false,
              focusNode: priceFocus,
              nextFocusNode: discountFocus,
              textInputAction: TextInputAction.next,
            ),
            PlaceOrderComponents.buildDialogInput(
              'Discount Percentage (%)',
              discountController,
              (v) => setState(() => discount = double.tryParse(v) ?? 0.0),
              focusNode: discountFocus,
              nextFocusNode: bonusFocus,
              textInputAction: TextInputAction.next,
            ),
            PlaceOrderComponents.buildDialogInput(
              'Bonus Amount (Rs)',
              bonusController,
              (v) => setState(() => bonus = double.tryParse(v) ?? 0.0),
              focusNode: bonusFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: _saveToCart,
            ),
            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calculated Subtotal:',
                  style: TextStyle(
                    color: ThemeManager.instance.getTextSecondary(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rs ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: ThemeManager.instance.getTextPrimary(),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                if (widget.existingItem != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.state.removeFromCart(
                          widget.product['product_id'].toString(),
                        );
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Remove'),
                    ),
                  ),
                if (widget.existingItem != null) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E56E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save to Cart',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousBookingDialog extends StatefulWidget {
  final String customerId;
  final String customerName;

  const _PreviousBookingDialog({
    required this.customerId,
    required this.customerName,
  });

  @override
  State<_PreviousBookingDialog> createState() => _PreviousBookingDialogState();
}

class _PreviousBookingDialogState extends State<_PreviousBookingDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  CustomerLastBooking? _lastBooking;

  @override
  void initState() {
    super.initState();
    _fetchLastBooking();
  }

  Future<void> _fetchLastBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.instance.fetchCustomerLastBooking(
        widget.customerId,
      );
      if (mounted) {
        setState(() {
          _lastBooking = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load booking: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatNaturalDateTime(String dateStr, String timeStr) {
    if (dateStr.isEmpty && timeStr.isEmpty) return 'Recent';

    DateTime? parsedDate;
    try {
      if (dateStr.contains('T')) {
        parsedDate = DateTime.tryParse(dateStr);
      } else if (dateStr.contains('-')) {
        final parts = dateStr.trim().split(' ')[0].split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            parsedDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else {
            // DD-MM-YYYY
            parsedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      }
    } catch (_) {}

    String formattedTime = '';
    if (timeStr.isNotEmpty) {
      try {
        final cleanTime = timeStr.trim();
        if (cleanTime.toLowerCase().contains('am') ||
            cleanTime.toLowerCase().contains('pm')) {
          formattedTime = cleanTime;
        } else {
          final tParts = cleanTime.split(':');
          if (tParts.length >= 2) {
            int hour = int.parse(tParts[0]);
            final minute = tParts[1].padLeft(2, '0');
            final ampm = hour >= 12 ? 'PM' : 'AM';
            if (hour == 0) {
              hour = 12;
            } else if (hour > 12) {
              hour -= 12;
            }
            formattedTime = '$hour:$minute $ampm';
          }
        }
      } catch (_) {
        formattedTime = timeStr;
      }
    }

    if (parsedDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthName = months[parsedDate.month - 1];

      String dayPrefix;
      if (itemDate == today) {
        dayPrefix = 'Today';
      } else if (itemDate == yesterday) {
        dayPrefix = 'Yesterday';
      } else if (now.year == parsedDate.year) {
        dayPrefix = '${parsedDate.day} $monthName';
      } else {
        dayPrefix = '${parsedDate.day} $monthName ${parsedDate.year}';
      }

      if (formattedTime.isNotEmpty) {
        return '$dayPrefix, $formattedTime';
      }
      return dayPrefix;
    }

    if (dateStr.isNotEmpty && formattedTime.isNotEmpty) {
      return '$dateStr, $formattedTime';
    }
    return dateStr.isNotEmpty ? dateStr : formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.instance;
    final isDark = !theme.isLightMode;

    return Dialog(
      backgroundColor: theme.getSurfaceColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.getBorderColor(), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9D54).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFFFF9D54),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Previous Booking',
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.customerName,
                          style: TextStyle(
                            color: theme.getTextSecondary(),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Refresh button in dialogue
                  IconButton(
                    onPressed: _isLoading ? null : _fetchLastBooking,
                    icon: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.getAccentBlue(),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: theme.getAccentBlue(),
                            size: 22,
                          ),
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.getTextSecondary(),
                      size: 22,
                    ),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Body
            Flexible(child: _buildDialogBody(theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogBody(ThemeManager theme, bool isDark) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.getAccentBlue(),
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Fetching customer history...',
                style: TextStyle(color: theme.getTextSecondary(), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red[400],
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.getTextPrimary(), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLastBooking,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E56E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final booking = _lastBooking;
    if (booking == null || booking.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.getListItemColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.getBorderColor()),
                ),
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  size: 28,
                  color: theme.getTextTertiary(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Previous Bookings',
                style: TextStyle(
                  color: theme.getTextPrimary(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No previous booking history was found for this customer.',
                style: TextStyle(color: theme.getTextSecondary(), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _fetchLastBooking,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.getAccentBlue(),
                  side: BorderSide(color: theme.getAccentBlue()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Summary Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.getListItemColor(),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.getBorderColor()),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Invoice ',
                          style: TextStyle(
                            color: theme.getTextSecondary(),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '#${booking.invoiceNo}',
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatNaturalDateTime(
                        booking.bookingDate,
                        booking.bookingTime,
                      ),
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${booking.totalItems} Products (${booking.totalQty} Units)',
                      style: TextStyle(
                        color: theme.getTextSecondary(),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rs. ${booking.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF9D54),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Order Items',
            style: TextStyle(
              color: theme.getTextPrimary(),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Items List
          ...booking.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E253A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.getBorderColor()),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.prodName,
                          style: TextStyle(
                            color: theme.getTextPrimary(),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Qty: ${item.qty}',
                              style: TextStyle(
                                color: theme.getTextSecondary(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '@ Rs. ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.getTextSecondary(),
                                fontSize: 12,
                              ),
                            ),
                            if (item.bonus > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+${item.bonus.toStringAsFixed(0)} Bns',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (item.discount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${item.discount.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rs. ${item.lineTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.getTextPrimary(),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
