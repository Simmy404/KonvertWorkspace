import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
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
    if (trimmed.toLowerCase().contains('am') ||
        trimmed.toLowerCase().contains('pm')) {
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

  Future<void> _editInvoice(
    BuildContext context,
    List<BookingData> items,
  ) async {
    final result = await Navigator.push(
      context,
      PageTransitions.fadeTransition(
        PlaceOrderScreen(existingInvoiceItems: items),
      ),
    );
    if (result == true) {
      _viewModel.fetchBookings();
    }
  }

  Future<void> _deleteInvoice(BuildContext context, int invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeManager.instance.getSurfaceColor(),
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
          style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
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

  void _downloadBookings(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet

    if (_viewModel.groupedBookings.isEmpty) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'NO_BOOKINGS',
          technicalDetails: 'No local bookings available to download',
        ),
        2,
      );
      return;
    }

    // Generate CSV contents
    // customer id, product id, quantity, discount, product price, bonus
    List<Map<String, String>> csvList = [];

    _viewModel.groupedBookings.forEach((invoice, items) {
      StringBuffer csvContent = StringBuffer();
      for (var item in items) {
        csvContent.writeln('${item.bookingCustId},${item.bookingProdId},${item.bookingQty},${item.bookingDiscount},${item.bookingPrice},${item.bookingBonus}');
      }
      csvList.add({
        'invoice': invoice.toString(),
        'content': csvContent.toString(),
      });
    });

    // Show dialog with CSV contents
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeManager.instance.getSurfaceColor(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Generated CSVs',
            style: TextStyle(
              color: ThemeManager.instance.getMatchColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: csvList.length,
              itemBuilder: (context, index) {
                final csvData = csvList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${csvData['invoice']}',
                        style: TextStyle(
                          color: ThemeManager.instance.getMatchColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeManager.instance.getContainerColor(),
                          border: Border.all(color: ThemeManager.instance.getBorderColor()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          csvData['content']!,
                          style: TextStyle(
                            color: ThemeManager.instance.getTextSecondary(),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: ThemeManager.instance.getTextSecondary()),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Directory? directory;
                  if (Platform.isAndroid) {
                    directory = Directory('/storage/emulated/0/Download');
                    if (!await directory.exists()) {
                      directory = await getExternalStorageDirectory();
                    }
                  } else {
                    directory = await getApplicationDocumentsDirectory();
                  }

                  if (directory != null) {
                    for (var csvData in csvList) {
                      final file = File('${directory.path}/invoice_${csvData['invoice']}.csv');
                      await file.writeAsString(csvData['content']!);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved to ${directory.path}'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ErrorManager.instance.showToastError(
                      ErrorStruct(
                        code: 'SAVE_FAILED',
                        technicalDetails: 'Failed to save CSVs: $e',
                      ),
                      3,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.instance.getPrimaryColor(),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Local'),
            ),
          ],
        );
      },
    );
  }

  void _showExportOptions(BuildContext context) {
    final isDark = !ThemeManager.instance.isLightMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeManager.instance.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: ThemeManager.instance.getBorderColor()),
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
                  color: ThemeManager.instance.getDividerColor(),
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
              leading: Icon(
                Icons.cloud_upload_rounded,
                color: ThemeManager.instance.getPrimaryColor(),
              ),
              title: Text(
                'Upload Bookings',
                style: TextStyle(color: ThemeManager.instance.getMatchColor()),
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                DashboardViewModel? dashVM;
                try {
                  dashVM = Provider.of<DashboardViewModel>(
                    context,
                    listen: false,
                  );
                } catch (_) {}

                Navigator.pop(context);

                if (_viewModel.allBookings.isEmpty) {
                  ErrorManager.instance.showToastError(
                    const ErrorStruct(
                      code: 'NO_BOOKINGS',
                      technicalDetails: 'No local bookings available to upload',
                    ),
                    2,
                  );
                  return;
                }

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Uploading bookings to server...'),
                    duration: Duration(seconds: 15),
                  ),
                );

                try {
                  final success = await _viewModel.uploadBookings(
                    dashboardViewModel: dashVM,
                  );
                  messenger.hideCurrentSnackBar();
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Bookings uploaded successfully!'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  } else {
                    ErrorManager.instance.showToastError(
                      const ErrorStruct(
                        code: 'UPLOAD_FAILED',
                        technicalDetails: 'Failed to upload bookings to server',
                      ),
                      3,
                    );
                  }
                } catch (e) {
                  messenger.hideCurrentSnackBar();
                  ErrorManager.instance.showToastError(
                    ErrorStruct(
                      code: 'UPLOAD_ERROR',
                      technicalDetails: 'Error during upload: $e',
                    ),
                    3,
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.download_rounded,
                color: ThemeManager.instance.getPrimaryColor(),
              ),
              title: Text(
                'Download Bookings',
                style: TextStyle(color: ThemeManager.instance.getMatchColor()),
              ),
              onTap: () => _downloadBookings(context),
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
                backgroundColor: Colors.transparent,
                body: SafeArea(
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
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.hexagon_outlined,
                                    color: ThemeManager.instance
                                        .getMatchColor(),
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

                        // Main Title: "Bookings"
                        Text(
                          'Bookings',
                          style: TextStyle(
                            color: ThemeManager.instance.isLightMode
                                ? const Color(0xFF0022FF)
                                : Colors.white,
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
                            color: ThemeManager.instance.getSurfaceColor(),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: ThemeManager.instance.getBorderColor(),
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: ThemeManager.instance.getTextTertiary(),
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
                                    color: ThemeManager.instance
                                        .getMatchColor(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search ${viewModel.groupedBookings.length} Bookings',
                                    hintStyle: TextStyle(
                                      color: ThemeManager.instance
                                          .getTextSecondary(),
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
                                    color: ThemeManager.instance
                                        .getTextTertiary(),
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
                                      color: ThemeManager.instance
                                          .getPrimaryColor(),
                                    ),
                                  )
                                : filteredGrouped.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.4,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.receipt_long_outlined,
                                                size: 64,
                                                color: ThemeManager.instance
                                                    .getTextTertiary(),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                viewModel
                                                        .groupedBookings
                                                        .isEmpty
                                                    ? 'No bookings found'
                                                    : 'No matching bookings found',
                                                style: TextStyle(
                                                  color: ThemeManager.instance
                                                      .getTextSecondary(),
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                          parent: BouncingScrollPhysics(),
                                        ),
                                    itemCount: filteredGrouped.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == filteredGrouped.length) {
                                        // Spacing for floating bottom navbar
                                        return const SizedBox(height: 90);
                                      }

                                      final invoice = filteredGrouped.keys
                                          .elementAt(index);
                                      final items = filteredGrouped[invoice]!;
                                      final isExpanded = _expandedInvoices
                                          .contains(invoice);

                                      final grandTotal = items.fold<double>(
                                        0,
                                        (sum, b) => sum + b.bookingGrandTotal,
                                      );
                                      final timeStr = _formatBookingTime(
                                        items.first.bookingTime,
                                      );
                                      final customerName = viewModel
                                          .getCustomerName(
                                            items.first.bookingCustId,
                                          );
                                      final remarks = items.first.bookingRemarks
                                          .trim();

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ThemeManager.instance
                                                .getListItemColor(),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              onTap: () {
                                                setState(() {
                                                  if (isExpanded) {
                                                    _expandedInvoices.remove(
                                                      invoice,
                                                    );
                                                  } else {
                                                    _expandedInvoices.add(
                                                      invoice,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Header Row (Time Pill, Customer Name, Summary, Arrow)
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // Time Pill
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                ThemeManager
                                                                    .instance
                                                                    .isLightMode
                                                                ? const Color(
                                                                    0xFFD4E3FB,
                                                                  )
                                                                : const Color(
                                                                    0xFF1A2C4D,
                                                                  ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            timeStr,
                                                            style: TextStyle(
                                                              color:
                                                                  ThemeManager
                                                                      .instance
                                                                      .isLightMode
                                                                  ? const Color(
                                                                      0xFF4F73A6,
                                                                    )
                                                                  : const Color(
                                                                      0xFF83ABED,
                                                                    ),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 14,
                                                        ),

                                                        // Name & Subtitle Summary
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                customerName,
                                                                style: TextStyle(
                                                                  color: ThemeManager
                                                                      .instance
                                                                      .getTextPrimary(),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      -0.3,
                                                                  height: 1,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${items.length} products | Total: ${_formatCurrency(grandTotal)}',
                                                                style: TextStyle(
                                                                  color: ThemeManager
                                                                      .instance
                                                                      .getTextSecondary(),
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        // Expand/Collapse Chevron Icon
                                                        Icon(
                                                          isExpanded
                                                              ? Icons
                                                                    .keyboard_arrow_up_rounded
                                                              : Icons
                                                                    .keyboard_arrow_down_rounded,
                                                          color: ThemeManager
                                                              .instance
                                                              .getTextSecondary(),
                                                          size: 26,
                                                        ),
                                                      ],
                                                    ),

                                                    // Expanded Content Section
                                                    if (isExpanded) ...[
                                                      const SizedBox(
                                                        height: 14,
                                                      ),

                                                      // Action Buttons (Edit & Delete)
                                                      Row(
                                                        children: [
                                                          // Edit Button
                                                          Expanded(
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    _editInvoice(
                                                                      context,
                                                                      items,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        ThemeManager
                                                                            .instance
                                                                            .isLightMode
                                                                        ? const Color(
                                                                            0xFFE2F1FE,
                                                                          )
                                                                        : const Color(
                                                                            0xFF19253B,
                                                                          ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .mode_edit_outline_rounded,
                                                                        color: const Color(
                                                                          0xFFEE8B38,
                                                                        ),
                                                                        size:
                                                                            18,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Edit',
                                                                        style: TextStyle(
                                                                          color: const Color(
                                                                            0xFFEE8B38,
                                                                          ),
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),

                                                          // Delete Button
                                                          Expanded(
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    _deleteInvoice(
                                                                      context,
                                                                      invoice,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        ThemeManager
                                                                            .instance
                                                                            .isLightMode
                                                                        ? const Color(
                                                                            0xFFE2F1FE,
                                                                          )
                                                                        : const Color(
                                                                            0xFF19253B,
                                                                          ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .delete_outline_rounded,
                                                                        color: const Color(
                                                                          0xFFF55454,
                                                                        ),
                                                                        size:
                                                                            18,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Delete',
                                                                        style: TextStyle(
                                                                          color: const Color(
                                                                            0xFFF55454,
                                                                          ),
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
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
                                                      if (remarks
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: ThemeManager
                                                                .instance
                                                                .getSurfaceColor(),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            border: Border.all(
                                                              color: ThemeManager
                                                                  .instance
                                                                  .getBorderColor(),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .note_alt_outlined,
                                                                size: 16,
                                                                color:
                                                                    ThemeManager
                                                                        .instance
                                                                        .isLightMode
                                                                    ? const Color(
                                                                        0xFF1E56E2,
                                                                      )
                                                                    : const Color(
                                                                        0xFF829AB1,
                                                                      ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Remarks',
                                                                      style: TextStyle(
                                                                        color:
                                                                            ThemeManager.instance.isLightMode
                                                                            ? const Color(
                                                                                0xFF1E56E2,
                                                                              )
                                                                            : const Color(
                                                                                0xFF829AB1,
                                                                              ),
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 2,
                                                                    ),
                                                                    Text(
                                                                      remarks,
                                                                      style: TextStyle(
                                                                        color: ThemeManager
                                                                            .instance
                                                                            .getMatchColor(),
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w500,
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Divider(
                                                        color:
                                                            !ThemeManager
                                                                .instance
                                                                .isLightMode
                                                            ? Colors.white
                                                                  .withOpacity(
                                                                    0.08,
                                                                  )
                                                            : Colors.black
                                                                  .withOpacity(
                                                                    0.06,
                                                                  ),
                                                        height: 1,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      ...items.map(
                                                        (b) => Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 4,
                                                              ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Product ID #${b.bookingProdId}',
                                                                style: TextStyle(
                                                                  color: ThemeManager
                                                                      .instance
                                                                      .getMatchColor()
                                                                      .withOpacity(
                                                                        0.9,
                                                                      ),
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Qty: ${b.bookingQty}  •  ${_formatCurrency(b.bookingGrandTotal)}',
                                                                style: TextStyle(
                                                                  color:
                                                                      !ThemeManager
                                                                          .instance
                                                                          .isLightMode
                                                                      ? const Color(
                                                                          0xFF94A3B8,
                                                                        )
                                                                      : const Color(
                                                                          0xFF64748B,
                                                                        ),
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
              );
            },
          ),
        );
      },
    );
  }
}
