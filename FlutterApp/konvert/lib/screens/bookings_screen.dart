import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_data.dart';
import '../models/error_struct.dart';
import '../managers/error_manager.dart';
import '../managers/theme_manager.dart';
import '../utils/page_transitions.dart';
import 'place_order_screen.dart';
import 'dashboard/bookings_view_model.dart';
import 'dashboard/dashboard_view_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late BookingsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedInvoices = {};
  bool _wasActive = false;
  bool _initializedExpanded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingsViewModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final int val = amount.round();
    final String str = val.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return 'Rs $formatted';
  }

  String _formatBookingTime(String rawTime) {
    if (rawTime.trim().isEmpty) return '11:30am';
    final trimmed = rawTime.trim();
    if (trimmed.toLowerCase().contains('am') || trimmed.toLowerCase().contains('pm')) {
      return trimmed;
    }
    try {
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1].padLeft(2, '0');
        final period = hour >= 12 ? 'pm' : 'am';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        return '$hour:${minute}$period';
      }
    } catch (_) {}
    return trimmed;
  }

  Future<void> _editInvoice(BuildContext context, List<BookingData> items) async {
    final result = await Navigator.push(
      context,
      PageTransitions.fadeTransition(PlaceOrderScreen(existingInvoiceItems: items)),
    );
    if (result == true) {
      _viewModel.fetchBookings();
    }
  }

  Future<void> _deleteInvoice(BuildContext context, int invoice) async {
    final isDark = !ThemeManager.instance.isLightMode;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Invoice',
          style: TextStyle(
            color: ThemeManager.instance.getMatchColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete invoice #$invoice?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _viewModel.deleteInvoice(invoice);
    }
  }

  void _showExportOptions(BuildContext context) {
    final isDark = !ThemeManager.instance.isLightMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Actions',
              style: TextStyle(
                color: ThemeManager.instance.getMatchColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.refresh_rounded, color: ThemeManager.instance.getPrimaryColor()),
              title: Text('Refresh Bookings', style: TextStyle(color: ThemeManager.instance.getMatchColor())),
              onTap: () {
                Navigator.pop(context);
                _viewModel.fetchBookings();
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload_rounded, color: ThemeManager.instance.getPrimaryColor()),
              title: Text('Upload Bookings', style: TextStyle(color: ThemeManager.instance.getMatchColor())),
              onTap: () {
                Navigator.pop(context);
                ErrorManager.instance.showToastError(
                  const ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Upload feature coming soon'),
                  2,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download_rounded, color: ThemeManager.instance.getPrimaryColor()),
              title: Text('Download Bookings', style: TextStyle(color: ThemeManager.instance.getMatchColor())),
              onTap: () {
                Navigator.pop(context);
                ErrorManager.instance.showToastError(
                  const ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Download feature coming soon'),
                  2,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh when Bookings tab becomes active
    final dashboardVM = context.watch<DashboardViewModel>();
    final isBookingsTab = dashboardVM.selectedIndex == 1;
    if (isBookingsTab && !_wasActive) {
      _wasActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.fetchBookings();
      });
    } else if (!isBookingsTab) {
      _wasActive = false;
    }

    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        final isDark = !ThemeManager.instance.isLightMode;

        return ChangeNotifierProvider.value(
          value: _viewModel,
          child: Consumer<BookingsViewModel>(
            builder: (context, viewModel, child) {
              final filteredGrouped = viewModel.filteredGroupedBookings;

              // Expand first card by default on first load
              if (!_initializedExpanded && filteredGrouped.isNotEmpty) {
                _initializedExpanded = true;
                _expandedInvoices.add(filteredGrouped.keys.first);
              }

              return Scaffold(
                backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8FAFC),
                body: Stack(
                  children: [
                    // Main Theme Background Image
                    Positioned.fill(
                      child: Image.asset(
                        ThemeManager.instance.getMainBG(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: isDark ? const Color(0xFF000000) : const Color(0xFFF8FAFC),
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // Header Top Bar: Logo Mark & Action Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  ThemeManager.instance.getLogoMark(),
                                  height: 32,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.hexagon_outlined,
                                    color: ThemeManager.instance.getMatchColor(),
                                    size: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _showExportOptions(context),
                                  icon: Icon(
                                    Icons.ios_share_rounded,
                                    color: ThemeManager.instance.getMatchColor(),
                                    size: 24,
                                  ),
                                  tooltip: 'Export & Options',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Main Title: "Bookings"
                            Text(
                              'Bookings',
                              style: TextStyle(
                                color: ThemeManager.instance.getMatchColor(),
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Search Bar
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0C1427).withOpacity(0.65)
                                    : Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.1),
                                  width: 1.2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: isDark
                                        ? const Color(0xFF829AB1)
                                        : const Color(0xFF64748B),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) {
                                        viewModel.setSearchQuery(val);
                                      },
                                      style: TextStyle(
                                        color: ThemeManager.instance.getMatchColor(),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search ${viewModel.groupedBookings.length} Bookings',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        viewModel.setSearchQuery('');
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: isDark
                                            ? const Color(0xFF829AB1)
                                            : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bookings List Area
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => viewModel.fetchBookings(),
                                color: ThemeManager.instance.getPrimaryColor(),
                                child: viewModel.isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: ThemeManager.instance.getPrimaryColor(),
                                        ),
                                      )
                                    : filteredGrouped.isEmpty
                                        ? ListView(
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.4,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.receipt_long_outlined,
                                                        size: 64,
                                                        color: isDark
                                                            ? Colors.white38
                                                            : Colors.black26,
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text(
                                                        viewModel.groupedBookings.isEmpty
                                                            ? 'No bookings found'
                                                            : 'No matching bookings found',
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.white54
                                                              : Colors.black54,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : ListView.builder(
                                            physics: const BouncingScrollPhysics(),
                                            itemCount: filteredGrouped.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index == filteredGrouped.length) {
                                                // Spacing for floating bottom navbar
                                                return const SizedBox(height: 90);
                                              }

                                              final invoice = filteredGrouped.keys.elementAt(index);
                                              final items = filteredGrouped[invoice]!;
                                              final isExpanded = _expandedInvoices.contains(invoice);

                                              final grandTotal = items.fold<double>(
                                                0,
                                                (sum, b) => sum + b.bookingGrandTotal,
                                              );
                                              final timeStr = _formatBookingTime(items.first.bookingTime);
                                              final customerName = viewModel.getCustomerName(items.first.bookingCustId);
                                              final remarks = items.first.bookingRemarks.trim();

                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 250),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(0xFF141824).withOpacity(0.9)
                                                        : Colors.white.withOpacity(0.95),
                                                    borderRadius: BorderRadius.circular(18),
                                                    border: Border.all(
                                                      color: isDark
                                                          ? Colors.white.withOpacity(0.08)
                                                          : Colors.black.withOpacity(0.06),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: isDark
                                                            ? Colors.black.withOpacity(0.3)
                                                            : Colors.black.withOpacity(0.04),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    borderRadius: BorderRadius.circular(18),
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(18),
                                                      onTap: () {
                                                        setState(() {
                                                          if (isExpanded) {
                                                            _expandedInvoices.remove(invoice);
                                                          } else {
                                                            _expandedInvoices.add(invoice);
                                                          }
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // Header Row (Time Pill, Customer Name, Summary, Arrow)
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                // Time Pill
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 12,
                                                                    vertical: 6,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: isDark
                                                                        ? const Color(0xFF1E293D)
                                                                        : const Color(0xFFE2E8F0),
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  child: Text(
                                                                    timeStr,
                                                                    style: TextStyle(
                                                                      color: isDark
                                                                          ? const Color(0xFF829AB1)
                                                                          : const Color(0xFF475569),
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 14),

                                                                // Name & Subtitle Summary
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        customerName,
                                                                        style: TextStyle(
                                                                          color: ThemeManager.instance.getMatchColor(),
                                                                          fontSize: 17,
                                                                          fontWeight: FontWeight.bold,
                                                                          letterSpacing: -0.3,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 2),
                                                                      Text(
                                                                        '${items.length} products | Total: ${_formatCurrency(grandTotal)}',
                                                                        style: TextStyle(
                                                                          color: isDark
                                                                              ? const Color(0xFF94A3B8)
                                                                              : const Color(0xFF64748B),
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                // Expand/Collapse Chevron Icon
                                                                Icon(
                                                                  isExpanded
                                                                      ? Icons.keyboard_arrow_up_rounded
                                                                      : Icons.keyboard_arrow_down_rounded,
                                                                  color: isDark
                                                                      ? const Color(0xFF94A3B8)
                                                                      : const Color(0xFF64748B),
                                                                  size: 26,
                                                                ),
                                                              ],
                                                            ),

                                                            // Expanded Content Section
                                                            if (isExpanded) ...[
                                                              const SizedBox(height: 14),

                                                              // Action Buttons (Edit & Delete)
                                                              Row(
                                                                children: [
                                                                  // Edit Button
                                                                  Expanded(
                                                                    child: Material(
                                                                      color: Colors.transparent,
                                                                      child: InkWell(
                                                                        onTap: () => _editInvoice(context, items),
                                                                        borderRadius: BorderRadius.circular(12),
                                                                        child: Container(
                                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                                          decoration: BoxDecoration(
                                                                            color: isDark
                                                                                ? const Color(0xFF1E293D)
                                                                                : const Color(0xFFEFF6FF),
                                                                            borderRadius: BorderRadius.circular(12),
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.mode_edit_outline_rounded,
                                                                                color: isDark
                                                                                    ? const Color(0xFFFACC15)
                                                                                    : const Color(0xFFD97706),
                                                                                size: 18,
                                                                              ),
                                                                              const SizedBox(width: 8),
                                                                              Text(
                                                                                'Edit',
                                                                                style: TextStyle(
                                                                                  color: isDark
                                                                                      ? const Color(0xFFFACC15)
                                                                                      : const Color(0xFFD97706),
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 10),

                                                                  // Delete Button
                                                                  Expanded(
                                                                    child: Material(
                                                                      color: Colors.transparent,
                                                                      child: InkWell(
                                                                        onTap: () => _deleteInvoice(context, invoice),
                                                                        borderRadius: BorderRadius.circular(12),
                                                                        child: Container(
                                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                                          decoration: BoxDecoration(
                                                                            color: isDark
                                                                                ? const Color(0xFF1E293D)
                                                                                : const Color(0xFFFEF2F2),
                                                                            borderRadius: BorderRadius.circular(12),
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.delete_outline_rounded,
                                                                                color: isDark
                                                                                    ? const Color(0xFFF87171)
                                                                                    : const Color(0xFFDC2626),
                                                                                size: 18,
                                                                              ),
                                                                              const SizedBox(width: 8),
                                                                              Text(
                                                                                'Delete',
                                                                                style: TextStyle(
                                                                                  color: isDark
                                                                                      ? const Color(0xFFF87171)
                                                                                      : const Color(0xFFDC2626),
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              // Order Remarks (if present)
                                                              if (remarks.isNotEmpty) ...[
                                                                const SizedBox(height: 12),
                                                                Container(
                                                                  width: double.infinity,
                                                                  padding: const EdgeInsets.all(12),
                                                                  decoration: BoxDecoration(
                                                                    color: isDark
                                                                        ? const Color(0xFF0F172A)
                                                                        : const Color(0xFFF1F5F9),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(
                                                                      color: isDark
                                                                          ? Colors.white.withOpacity(0.06)
                                                                          : Colors.black.withOpacity(0.05),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.note_alt_outlined,
                                                                        size: 16,
                                                                        color: isDark
                                                                            ? const Color(0xFF829AB1)
                                                                            : const Color(0xFF1E56E2),
                                                                      ),
                                                                      const SizedBox(width: 8),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Remarks',
                                                                              style: TextStyle(
                                                                                color: isDark
                                                                                    ? const Color(0xFF829AB1)
                                                                                    : const Color(0xFF1E56E2),
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 2),
                                                                            Text(
                                                                              remarks,
                                                                              style: TextStyle(
                                                                                color: ThemeManager.instance.getMatchColor(),
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],

                                                              // Product items detail breakdown
                                                              const SizedBox(height: 10),
                                                              Divider(
                                                                color: isDark
                                                                    ? Colors.white.withOpacity(0.08)
                                                                    : Colors.black.withOpacity(0.06),
                                                                height: 1,
                                                              ),
                                                              const SizedBox(height: 8),
                                                              ...items.map(
                                                                (b) => Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        'Product ID #${b.bookingProdId}',
                                                                        style: TextStyle(
                                                                          color: ThemeManager.instance.getMatchColor().withOpacity(0.9),
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Qty: ${b.bookingQty}  •  ${_formatCurrency(b.bookingGrandTotal)}',
                                                                        style: TextStyle(
                                                                          color: isDark
                                                                              ? const Color(0xFF94A3B8)
                                                                              : const Color(0xFF64748B),
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
