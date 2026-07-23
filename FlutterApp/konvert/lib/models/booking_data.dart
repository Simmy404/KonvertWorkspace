// lib/models/booking_data.dart

class BookingData {
  int bookingInvoice;
  int bookingBrikId;
  int bookingCustId;
  int bookingProdId;
  int bookingQty;
  double bookingBonus;
  double bookingDiscount;
  double bookingPrice;
  double bookingLong;
  double bookingLat;
  String bookingDate;
  String bookingTime;
  double bookingGrandTotal;
  int bookingProdCount;
  String bookingRemarks;

  BookingData({
    required this.bookingInvoice,
    required this.bookingBrikId,
    required this.bookingCustId,
    required this.bookingProdId,
    required this.bookingQty,
    this.bookingBonus = 0.0,
    this.bookingDiscount = 0.0,
    required this.bookingPrice,
    required this.bookingLong,
    required this.bookingLat,
    required this.bookingDate,
    required this.bookingTime,
    required this.bookingProdCount,
    this.bookingRemarks = "",
  }) : bookingGrandTotal =
           (bookingPrice * bookingQty) - bookingDiscount + bookingBonus;

  BookingData.copy(BookingData other)
    : bookingInvoice = other.bookingInvoice,
      bookingBrikId = other.bookingBrikId,
      bookingCustId = other.bookingCustId,
      bookingProdId = other.bookingProdId,
      bookingQty = other.bookingQty,
      bookingBonus = other.bookingBonus,
      bookingDiscount = other.bookingDiscount,
      bookingPrice = other.bookingPrice,
      bookingLong = other.bookingLong,
      bookingLat = other.bookingLat,
      bookingDate = other.bookingDate,
      bookingTime = other.bookingTime,
      bookingProdCount = other.bookingProdCount,
      bookingGrandTotal = other.bookingGrandTotal,
      bookingRemarks = other.bookingRemarks;

  double calculateGrandTotal() {
    return (bookingPrice * bookingQty) - bookingDiscount + bookingBonus;
  }

  // Convert to Map for SQLite or API
  Map<String, dynamic> toJson() {
    return {
      'booking_invoice': bookingInvoice,
      'booking_brikid': bookingBrikId,
      'booking_custid': bookingCustId,
      'booking_prodid': bookingProdId,
      'booking_qty': bookingQty,
      'booking_bonus': bookingBonus,
      'booking_discount': bookingDiscount,
      'booking_price': bookingPrice,
      'booking_long': bookingLong,
      'booking_lat': bookingLat,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'booking_grand_total': bookingGrandTotal,
      'booking_prod_count': bookingProdCount,
      'booking_remarks': bookingRemarks,
    };
  }

  // Create from Map (SQLite or API response)
  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
        bookingInvoice:
            int.tryParse(json['booking_invoice']?.toString() ?? '0') ?? 0,
        bookingBrikId:
            int.tryParse(json['booking_brikid']?.toString() ?? '0') ?? 0,
        bookingCustId:
            int.tryParse(json['booking_custid']?.toString() ?? '0') ?? 0,
        bookingProdId:
            int.tryParse(json['booking_prodid']?.toString() ?? '0') ?? 0,
        bookingQty: int.tryParse(json['booking_qty']?.toString() ?? '0') ?? 0,
        bookingBonus:
            double.tryParse(json['booking_bonus']?.toString() ?? '0.0') ?? 0.0,
        bookingDiscount:
            double.tryParse(json['booking_discount']?.toString() ?? '0.0') ??
            0.0,
        bookingPrice:
            double.tryParse(json['booking_price']?.toString() ?? '0.0') ?? 0.0,
        bookingLong:
            double.tryParse(json['booking_long']?.toString() ?? '0.0') ?? 0.0,
        bookingLat:
            double.tryParse(json['booking_lat']?.toString() ?? '0.0') ?? 0.0,
        bookingDate: json['booking_date']?.toString() ?? "",
        bookingTime: json['booking_time']?.toString() ?? "",
        bookingProdCount:
            int.tryParse(json['booking_prod_count']?.toString() ?? '1') ?? 1,
        bookingRemarks: json['booking_remarks']?.toString() ?? "",
      )
      ..bookingGrandTotal =
          double.tryParse(json['booking_grand_total']?.toString() ?? '0.0') ??
          0.0;
  }
}
