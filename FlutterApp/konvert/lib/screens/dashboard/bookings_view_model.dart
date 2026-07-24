import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/booking_data.dart';

class BookingsViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool isLoading = true;
  List<BookingData> allBookings = [];
  Map<int, List<BookingData>> groupedBookings = {};
  Map<int, String> customerNames = {};
  String searchQuery = '';

  BookingsViewModel() {
    fetchBookings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    _safeNotifyListeners();
  }

  Future<void> fetchBookings() async {
    isLoading = true;
    _safeNotifyListeners();

    try {
      allBookings = await DatabaseService.instance.getAllBookings();
      final customers = await DatabaseService.instance.getAllCustomers();
      
      customerNames = {};
      for (var c in customers) {
        final idRaw = c['customer_id'];
        final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '') ?? 0;
        if (id != 0) {
          final name = c['customer_name']?.toString() ?? '';
          if (name.isNotEmpty) {
            customerNames[id] = name;
          }
        }
      }

      groupedBookings.clear();
      for (var booking in allBookings) {
        if (!groupedBookings.containsKey(booking.bookingInvoice)) {
          groupedBookings[booking.bookingInvoice] = [];
        }
        groupedBookings[booking.bookingInvoice]!.add(booking);
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Map<int, List<BookingData>> get filteredGroupedBookings {
    if (searchQuery.trim().isEmpty) {
      return groupedBookings;
    }
    final q = searchQuery.trim().toLowerCase();
    final Map<int, List<BookingData>> filtered = {};

    groupedBookings.forEach((invoice, items) {
      final custId = items.first.bookingCustId;
      final custName = getCustomerName(custId).toLowerCase();
      final invoiceStr = invoice.toString();
      final remarks = items.first.bookingRemarks.toLowerCase();

      if (invoiceStr.contains(q) || custName.contains(q) || remarks.contains(q)) {
        filtered[invoice] = items;
      }
    });

    return filtered;
  }

  String getCustomerName(int custId) {
    if (customerNames.containsKey(custId) && customerNames[custId]!.trim().isNotEmpty) {
      return customerNames[custId]!.trim();
    }
    return 'Ahmad Pharma';
  }

  Future<void> deleteInvoice(int invoice) async {
    await DatabaseService.instance.deleteBookingByInvoice(invoice.toString());
    await fetchBookings();
  }
}

