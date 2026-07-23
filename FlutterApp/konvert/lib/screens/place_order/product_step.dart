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
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: state.productSearchController,
              onChanged: state.filterProducts,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
              ),
              decoration: PlaceOrderComponents.buildSearchDecoration(
                'Search Products...',
                isDark,
                () {
                  state.productSearchController.clear();
                  state.filterProducts('');
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: state.filteredProducts.isEmpty
              ? PlaceOrderComponents.buildEmptyState(
                  'No Products found',
                  isDark,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    final prodId = product['product_id'].toString();

                    final cartItem = state.cart
                        .where((p) => p.prodID == prodId)
                        .firstOrNull;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121318) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: cartItem != null
                              ? const Color(0xFF1E56E2)
                              : (isDark
                                    ? const Color(0xFF22242E)
                                    : const Color(0xFFE2E8F0)),
                          width: cartItem != null ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F1E3D)
                                : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.medication_outlined,
                            color: Color(0xFF0284C7),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          product['product_name'] ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Row(
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
                            if (product['product_is_otc'] != null &&
                                product['product_is_otc'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Container(
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
                              ),
                          ],
                        ),
                        trailing: cartItem != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E56E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${cartItem.qty} Qty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E2C)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E56E2),
                                  size: 18,
                                ),
                              ),
                        onTap: () => _showAddToCartDialog(
                          context,
                          state,
                          product,
                          cartItem,
                          isDark,
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Compact Cart Summary Bottom Bar
        _buildBottomCartSummary(context, state, isDark),
      ],
    );
  }

  Widget _buildBottomCartSummary(
    BuildContext context,
    PlaceOrderState state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1437) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF003087).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF1E56E2),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.cart.length} ${state.cart.length == 1 ? 'Item' : 'Items'}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total: Rs ${state.cartGrandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: TextField(
                onChanged: (val) => state.remarks = val,
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
                    size: 15,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF121318)
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF22242E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF22242E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: state.cart.isEmpty
                    ? null
                    : () async {
                        final success = await state.confirmOrder();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order Placed Successfully!'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text(
                  'Confirm & Save Order',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E56E2),
                  disabledBackgroundColor: isDark
                      ? const Color(0xFF1E1E2C)
                      : const Color(0xFFCBD5E1),
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
    );
  }

  void _showAddToCartDialog(
    BuildContext context,
    PlaceOrderState state,
    Map<String, dynamic> product,
    PlaceOrderProduct? existingItem,
    bool isDark,
  ) {
    int qty = existingItem?.qty ?? 1;
    double price =
        existingItem?.price ??
        double.tryParse(product['product_tp'].toString()) ??
        0.0;
    double discount = existingItem?.discount ?? 0.0;
    double bonus = existingItem?.bonus ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double total =
                (price * qty) - ((price * qty * discount) / 100) + bonus;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF121318) : Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                product['product_name'] ?? 'Product Details',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity:',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (qty > 1) {
                                  setStateDialog(() => qty--);
                                }
                              },
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF1E56E2),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E2C)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$qty',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setStateDialog(() => qty++);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF1E56E2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PlaceOrderComponents.buildDialogInput(
                      'Price (TP)',
                      price.toString(),
                      (v) => setStateDialog(
                        () => price = double.tryParse(v) ?? 0.0,
                      ),
                      isDark,
                    ),
                    PlaceOrderComponents.buildDialogInput(
                      'Discount (%)',
                      discount.toString(),
                      (v) => setStateDialog(
                        () => discount = double.tryParse(v) ?? 0.0,
                      ),
                      isDark,
                    ),
                    PlaceOrderComponents.buildDialogInput(
                      'Bonus (Rs)',
                      bonus.toString(),
                      (v) => setStateDialog(
                        () => bonus = double.tryParse(v) ?? 0.0,
                      ),
                      isDark,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal:',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rs ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              actions: [
                if (existingItem != null)
                  TextButton(
                    onPressed: () {
                      state.removeFromCart(product['product_id'].toString());
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save to Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
