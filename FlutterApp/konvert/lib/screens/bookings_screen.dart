import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/error_struct.dart';
import '../managers/error_manager.dart';
import 'dashboard/bookings_view_model.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  Future<void> _deleteInvoice(BuildContext context, int invoice, BookingsViewModel viewModel) async {
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
      await viewModel.deleteInvoice(invoice);
    }
  }

  Future<void> _uploadBookings(BuildContext context) async {
    ErrorManager.instance.showToastError(ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Upload feature coming soon'), 2);
  }
  
  Future<void> _downloadBookings(BuildContext context) async {
    ErrorManager.instance.showToastError(ErrorStruct(code: 'COMING_SOON', technicalDetails: 'Download feature coming soon'), 2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider(
      create: (_) => BookingsViewModel(),
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
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.groupedBookings.isEmpty
                          ? Center(
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
                            )
                          : ListView.builder(
                              itemCount: viewModel.groupedBookings.length,
                              itemBuilder: (context, index) {
                                final invoice = viewModel.groupedBookings.keys.elementAt(index);
                                final items = viewModel.groupedBookings[invoice]!;
                                final grandTotal = items.fold<double>(0, (sum, b) => sum + b.bookingGrandTotal);
                                
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
                                      const Divider(),
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
                                              onPressed: () => _deleteInvoice(context, invoice, viewModel),
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
                const SizedBox(height: 80), // Padding for bottom nav bar
              ],
            ),
          );
        }
      ),
    );
  }
}
