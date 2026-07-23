import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_data.dart';
import '../models/error_struct.dart';
import '../managers/error_manager.dart';
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
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingsViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        title: Text('Delete Invoice', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure you want to delete invoice $invoice?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _viewModel.deleteInvoice(invoice);
    }
  }

  Future<void> _uploadBookings(BuildContext context) async {
    ErrorManager.instance.showToastError(
      ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Upload feature coming soon'),
      2,
    );
  }
  
  Future<void> _downloadBookings(BuildContext context) async {
    ErrorManager.instance.showToastError(
      ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Download feature coming soon'),
      2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<BookingsViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            color: isDark ? const Color(0xFF030305) : const Color(0xFFF4F6F9),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Sync Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bookings',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your saved orders',
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => viewModel.fetchBookings(),
                          icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
                          tooltip: 'Refresh Bookings',
                        ),
                        IconButton(
                          onPressed: () => _downloadBookings(context),
                          icon: Icon(Icons.download_rounded, color: isDark ? Colors.white : Colors.black),
                          tooltip: 'Download Bookings',
                        ),
                        IconButton(
                          onPressed: () => _uploadBookings(context),
                          icon: Icon(Icons.cloud_upload_rounded, color: isDark ? Colors.white : Colors.black),
                          tooltip: 'Upload Bookings',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => viewModel.fetchBookings(),
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : viewModel.groupedBookings.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No bookings found',
                                            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: viewModel.groupedBookings.length,
                                itemBuilder: (context, index) {
                                  final invoice = viewModel.groupedBookings.keys.elementAt(index);
                                  final items = viewModel.groupedBookings[invoice]!;
                                  final grandTotal = items.fold<double>(0, (sum, b) => sum + b.bookingGrandTotal);
                                  final remarks = items.first.bookingRemarks.trim();
                                  
                                  return Card(
                                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: ExpansionTile(
                                      iconColor: isDark ? Colors.white : Colors.black,
                                      collapsedIconColor: isDark ? Colors.white54 : Colors.black54,
                                      title: Text(
                                        'Invoice #$invoice',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${items.length} items | Total: Rs ${grandTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      children: [
                                        const Divider(height: 1),
                                        if (remarks.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF121318) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isDark ? const Color(0xFF22242E) : const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.note_alt_outlined,
                                                  size: 16,
                                                  color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Order Remarks',
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white70 : const Color(0xFF1E56E2),
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        remarks,
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ...items.map((b) => ListTile(
                                          title: Text('Product ID: ${b.bookingProdId}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                          subtitle: Text('Qty: ${b.bookingQty} | Total: ${b.bookingGrandTotal}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                                        )),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () => _editInvoice(context, items),
                                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E56E2)),
                                                label: const Text('Edit', style: TextStyle(color: Color(0xFF1E56E2))),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () => _deleteInvoice(context, invoice),
                                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
                const SizedBox(height: 80), // Padding for bottom nav bar
              ],
            ),
          );
        },
      ),
    );
  }
}
