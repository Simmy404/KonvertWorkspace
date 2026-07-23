import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_order_product.dart';
import 'place_order_state.dart';
import 'place_order_components.dart';

class ProductStep extends StatelessWidget {
  const ProductStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlaceOrderState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header, Search Box & Category Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Products',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.selectedCustomer != null)
                        Text(
                          '${state.selectedCustomer!['customer_name']}',
                          style: const TextStyle(
                            color: Color(0xFF1E56E2),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: state.isRefreshingProducts
                            ? null
                            : () => state.refreshProducts(),
                        icon: state.isRefreshingProducts
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1E56E2),
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                                size: 18,
                              ),
                        tooltip: 'Refresh Products',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 38,
                child: TextField(
                  controller: state.productSearchController,
                  onChanged: state.filterProducts,
                  enabled: !state.isRefreshingProducts,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  decoration: PlaceOrderComponents.buildSearchDecoration(
                    'Search Products by Name...',
                    isDark,
                    () {
                      state.productSearchController.clear();
                      state.filterProducts('');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PlaceOrderComponents.buildFilterChip(
                      label: 'All Products (${state.allProducts.length})',
                      isSelected: state.selectedProductCategoryFilter == 'all',
                      onTap: () => state.filterProductsByCategory('all'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'Rx (Prescription)',
                      icon: Icons.medication_outlined,
                      isSelected: state.selectedProductCategoryFilter == 'rx',
                      onTap: () => state.filterProductsByCategory('rx'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    PlaceOrderComponents.buildFilterChip(
                      label: 'OTC',
                      icon: Icons.local_pharmacy_outlined,
                      isSelected: state.selectedProductCategoryFilter == 'otc',
                      onTap: () => state.filterProductsByCategory('otc'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Products List (Disabled while refreshing)
        Expanded(
          child: IgnorePointer(
            ignoring: state.isRefreshingProducts,
            child: Opacity(
              opacity: state.isRefreshingProducts ? 0.5 : 1.0,
              child: state.filteredProducts.isEmpty
                  ? PlaceOrderComponents.buildEmptyState('No Products found', isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
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

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF121318) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cartItem != null
                                  ? const Color(0xFF1E56E2)
                                  : (isDark
                                        ? const Color(0xFF22242E)
                                        : const Color(0xFFE2E8F0)),
                              width: cartItem != null ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.2)
                                    : const Color(0xFF003087).withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                // Product Icon
                                GestureDetector(
                                  onTap: state.isRefreshingProducts
                                      ? null
                                      : () => _showProductPricingBottomSheet(
                                            context,
                                            state,
                                            product,
                                            cartItem,
                                            isDark,
                                          ),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0F1E3D)
                                          : const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.medication_outlined,
                                      color: Color(0xFF0284C7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Product Title & Price Details
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: state.isRefreshingProducts
                                        ? null
                                        : () => _showProductPricingBottomSheet(
                                              context,
                                              state,
                                              product,
                                              cartItem,
                                              isDark,
                                            ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product['product_name'] ?? '',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF0F172A),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
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
                                                color: isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF475569),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
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
                                ),

                                // Inline Quantity Stepper / Add Button
                                cartItem != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E1E2C)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFF1E56E2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                              onPressed: state.isRefreshingProducts
                                                  ? null
                                                  : () => state.decrementProductQty(prodId),
                                              icon: Icon(
                                                cartItem.qty == 1
                                                    ? Icons.delete_outline_rounded
                                                    : Icons.remove_rounded,
                                                size: 16,
                                                color: cartItem.qty == 1
                                                    ? Colors.red
                                                    : (isDark ? Colors.white : Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text(
                                                '${cartItem.qty}',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                              onPressed: state.isRefreshingProducts
                                                  ? null
                                                  : () => state.incrementProductQty(product),
                                              icon: const Icon(
                                                Icons.add_rounded,
                                                size: 16,
                                                color: Color(0xFF1E56E2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: state.isRefreshingProducts
                                            ? null
                                            : () => state.incrementProductQty(product),
                                        icon: const Icon(Icons.add_rounded, size: 14),
                                        label: const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E56E2),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          minimumSize: const Size(0, 30),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),

        // Modern Floating Bottom Cart Bar
        IgnorePointer(
          ignoring: state.isRefreshingProducts,
          child: Opacity(
            opacity: state.isRefreshingProducts ? 0.5 : 1.0,
            child: _buildBottomCartSummary(context, state, isDark),
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
    bool isDark,
  ) {
    final hasItems = state.cart.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1437) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E2D68).withOpacity(0.5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : const Color(0xFF003087).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Items Count & Grand Total
            GestureDetector(
              onTap: hasItems ? () => _showCartDetailsModal(context, state, isDark) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: hasItems ? const Color(0xFF1E56E2) : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.cart.length} ${state.cart.length == 1 ? 'Item' : 'Items'} in Cart',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasItems) const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: Color(0xFF1E56E2)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: Rs ${state.cartGrandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Primary Action Button
            ElevatedButton.icon(
              onPressed: hasItems
                  ? () => _showCartDetailsModal(context, state, isDark)
                  : null,
              icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
              label: Text(
                state.editingInvoiceNumber != null ? 'Update Order' : 'Review & Save',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E56E2),
                disabledBackgroundColor: isDark
                    ? const Color(0xFF1E1E2C)
                    : const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  // EXPANDABLE CART DETAILS MODAL BOTTOM SHEET
  // ==========================================
  void _showCartDetailsModal(
    BuildContext context,
    PlaceOrderState state,
    bool isDark,
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
                color: isDark ? const Color(0xFF0B1437) : Colors.white,
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
                      color: isDark ? Colors.white30 : Colors.grey.shade300,
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
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white70 : Colors.black87,
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
                            child: Text(
                              'Cart is empty',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
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
                                  color: isDark ? const Color(0xFF121318) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
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
                                              color: isDark ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'TP: Rs ${item.price} | Qty: ${item.qty}${item.discount > 0 ? ' | Disc: ${item.discount}%' : ''}${item.bonus > 0 ? ' | Bonus: Rs ${item.bonus}' : ''}',
                                            style: TextStyle(
                                              color: isDark ? Colors.white60 : Colors.black54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item.getGrandTotal().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                      color: isDark ? const Color(0xFF070C22) : const Color(0xFFF1F5F9),
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
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Order Remarks (Optional)...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.note_alt_outlined,
                              size: 16,
                              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF121318) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            onPressed: state.cart.isEmpty
                                ? null
                                : () async {
                                    final success = await state.confirmOrder();
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Order Saved Successfully!'),
                                          backgroundColor: Color(0xFF16A34A),
                                        ),
                                      );
                                      Navigator.pop(context); // close bottom sheet
                                      Navigator.pop(context, true); // close PlaceOrderScreen
                                    }
                                  },
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                            label: Text(
                              state.editingInvoiceNumber != null ? 'Save Changes' : 'Confirm & Save Order',
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
    PlaceOrderProduct? existingItem,
    bool isDark,
  ) {
    int qty = existingItem?.qty ?? 1;
    double price = existingItem?.price ?? double.tryParse(product['product_tp'].toString()) ?? 0.0;
    double discount = existingItem?.discount ?? 0.0;
    double bonus = existingItem?.bonus ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            double total = (price * qty) - ((price * qty * discount) / 100) + bonus;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121318) : Colors.white,
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
                            product['product_name'] ?? 'Product Pricing & Details',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quantity Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity:',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (qty > 1) {
                                  setStateModal(() => qty--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, size: 22),
                              color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$qty',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setStateModal(() => qty++),
                              icon: const Icon(Icons.add_circle_outline, size: 22),
                              color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    PlaceOrderComponents.buildDialogInput(
                      'Unit Price (TP)',
                      price.toString(),
                      (v) => setStateModal(() => price = double.tryParse(v) ?? 0.0),
                      isDark,
                    ),
                    PlaceOrderComponents.buildDialogInput(
                      'Discount Percentage (%)',
                      discount.toString(),
                      (v) => setStateModal(() => discount = double.tryParse(v) ?? 0.0),
                      isDark,
                    ),
                    PlaceOrderComponents.buildDialogInput(
                      'Bonus Amount (Rs)',
                      bonus.toString(),
                      (v) => setStateModal(() => bonus = double.tryParse(v) ?? 0.0),
                      isDark,
                    ),
                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Calculated Subtotal:',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        if (existingItem != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                state.removeFromCart(product['product_id'].toString());
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
                        if (existingItem != null) const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (qty > 0) {
                                final item = PlaceOrderProduct(
                                  prodID: product['product_id'].toString(),
                                  name: product['product_name'].toString(),
                                  qty: qty,
                                  price: price,
                                  discount: discount,
                                  bonus: bonus,
                                );
                                state.addToCart(item);
                              }
                              Navigator.pop(context);
                            },
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
          },
        );
      },
    );
  }
}
