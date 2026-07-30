import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/place_order_product.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlaceOrderComponents.buildSearchBar(
                controller: state.productSearchController,
                onChanged: state.filterProducts,
                hint: 'Search ${state.allProducts.length} Products',
                onClear: () => state.filterProducts(''),
                enabled: !state.isRefreshingProducts,
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

                        final isOtc = product['product_is_otc'] != null &&
                            product['product_is_otc'].toString().trim().isNotEmpty;

                        final isLight = theme.isLightMode;
                        final cardBg = isLight ? const Color(0xFFEFF4FD) : const Color(0xFF121624);
                        final cardBorder = isLight ? const Color(0xFFE2ECFC) : const Color(0xFF1E253A);
                        final circleBadgeBg = isLight ? const Color(0xFF3B82F6) : const Color(0xFF0055FF);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: cartItem != null
                                ? theme.getAccentBlue().withOpacity(isLight ? 0.08 : 0.2)
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product['product_name'] ?? '',
                                                style: TextStyle(
                                                  color: theme.getTextPrimary(),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isOtc) ...[
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'OTC',
                                                  style: TextStyle(
                                                    color: Color(0xFFD97706),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
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
                                                color: theme.getTextSecondary(),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (cartItem != null && (cartItem.discount > 0 || cartItem.bonus > 0)) ...[
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
                                      ? _buildQtyStepper(context, state, prodId, cartItem, theme)
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
  Widget _buildBottomCartSummary(
    BuildContext context,
    PlaceOrderState state,
  ) {
    final hasItems = state.cart.isNotEmpty;
    final theme = ThemeManager.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: theme.getContainerColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: theme.getBorderColor(),
          ),
        ),
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
                      Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: theme.getAccentBlue()),
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
                state.editingInvoiceNumber != null ? 'Update Order' : 'Review & Save',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.getAccentBlue(),
                disabledBackgroundColor: theme.isLightMode
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
          : () => _showQuickQtyDialog(context, state, prodId, cartItem.qty, theme),
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
                  : () => _showQuickQtyDialog(context, state, prodId, cartItem.qty, theme),
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
                  : () => state.incrementProductQty(
                        {'product_id': prodId, 'product_name': cartItem.name, 'product_tp': cartItem.price.toString()},
                      ),
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
      ..selection = TextSelection(baseOffset: 0, extentOffset: currentQty.toString().length);

    void setQtyAndPop(BuildContext ctx) {
      final newQty = int.tryParse(ctrl.text.trim()) ?? 0;
      if (newQty > 0) {
        final existing = state.cart.firstWhere((p) => p.prodID == prodId, orElse: () => throw Exception());
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
          style: TextStyle(color: theme.getTextPrimary(), fontWeight: FontWeight.bold),
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
            child: Text('Cancel', style: TextStyle(color: theme.getTextSecondary())),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.getAccentBlue(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => setQtyAndPop(ctx),
            child: const Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EXPANDABLE CART DETAILS MODAL BOTTOM SHEET
  // ==========================================
  void _showCartDetailsModal(
    BuildContext context,
    PlaceOrderState state,
  ) {
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
                                    color: ThemeManager.instance.getTextPrimary(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No products added. Tap confirm below to record visit.',
                                  style: TextStyle(
                                    color: ThemeManager.instance.getTextSecondary(),
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
                                  color: ThemeManager.instance.getContainerColor(),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ThemeManager.instance.getBorderColor(),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              color: ThemeManager.instance.getTextPrimary(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'TP: Rs ${item.price} | Qty: ${item.qty}${item.discount > 0 ? ' | Disc: ${item.discount}%' : ''}${item.bonus > 0 ? ' | Bonus: Rs ${item.bonus}' : ''}',
                                            style: TextStyle(
                                              color: ThemeManager.instance.getTextSecondary(),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item.getGrandTotal().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: ThemeManager.instance.getTextPrimary(),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
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
                            ..selection = TextSelection.collapsed(offset: state.remarks.length),
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
                            fillColor: ThemeManager.instance.getContainerColor(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEvidenceImagesSection(context, state, setModalState),
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
                                  Navigator.pop(context, true); // close PlaceOrderScreen if editing
                                } else {
                                  state.resetOrderAndGoToBricks(); // take user to Bricks step for new order
                                }
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                            label: Text(
                              state.cart.isEmpty
                                  ? 'Confirm Visit (No Order)'
                                  : (state.editingInvoiceNumber != null ? 'Save Changes' : 'Confirm & Save Order'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildEvidenceImagesSection(BuildContext context, PlaceOrderState state, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Evidence Images (${state.evidenceImages.length}/3)',
              style: TextStyle(
                color: ThemeManager.instance.getTextSecondary(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.evidenceImages.length < 3)
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Photo Library'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                                  if (image != null) {
                                    await state.addEvidenceImage(image.path);
                                    setModalState(() {});
                                  }
                                }),
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Camera'),
                              onTap: () async {
                                Navigator.of(context).pop();
                                final picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                                if (image != null) {
                                  await state.addEvidenceImage(image.path);
                                  setModalState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '+ Add Photo',
                    style: TextStyle(
                      color: Color(0xFF1E56E2),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (state.evidenceImages.isNotEmpty) const SizedBox(height: 8),
        if (state.evidenceImages.isNotEmpty)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.evidenceImages.length,
              itemBuilder: (context, index) {
                final path = state.evidenceImages[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        image: DecorationImage(
                          image: FileImage(File(path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          state.removeEvidenceImage(index);
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
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
  State<_ProductPricingDialogContent> createState() => _ProductPricingDialogContentState();
}

class _ProductPricingDialogContentState extends State<_ProductPricingDialogContent> {
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
    price = widget.existingItem?.price ?? double.tryParse(widget.product['product_tp'].toString()) ?? 0.0;
    discount = widget.existingItem?.discount ?? 0.0;
    bonus = widget.existingItem?.bonus ?? 0.0;

    qtyController = TextEditingController(text: qty.toString());
    priceController = TextEditingController(text: price.toString());
    discountController = TextEditingController(text: discount.toString());
    bonusController = TextEditingController(text: bonus.toString());

    // Initially select quantity text if autofocusing
    if (widget.autofocusFirstInput) {
      qtyController.selection = TextSelection(baseOffset: 0, extentOffset: qtyController.text.length);
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
        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
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
                    widget.product['product_name'] ?? 'Product Pricing & Details',
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
                        widget.state.removeFromCart(widget.product['product_id'].toString());
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
                    child: const Text('Save to Cart', style: TextStyle(fontWeight: FontWeight.bold)),
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
