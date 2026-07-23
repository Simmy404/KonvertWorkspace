import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/booking_data.dart';

class BookingsViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool isLoading = true;
  List<BookingData> allBookings = [];
  Map<int, List<BookingData>> groupedBookings = {};

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

  Future<void> fetchBookings() async {
    isLoading = true;
    _safeNotifyListeners();

    try {
      allBookings = await DatabaseService.instance.getAllBookings();
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

  Future<void> deleteInvoice(int invoice) async {
    await DatabaseService.instance.deleteBookingByInvoice(invoice.toString());
    await fetchBookings();
  }
}
