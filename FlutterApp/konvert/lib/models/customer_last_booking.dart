// lib/models/customer_last_booking.dart

class CustomerLastBooking {
  final int invoiceNo;
  final int customerId;
  final String customerName;
  final String bookingDate;
  final String bookingTime;
  final int totalItems;
  final int totalQty;
  final double grandTotal;
  final List<CustomerLastBookingItem> items;

  CustomerLastBooking({
    required this.invoiceNo,
    required this.customerId,
    required this.customerName,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalItems,
    required this.totalQty,
    required this.grandTotal,
    required this.items,
  });

  factory CustomerLastBooking.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CustomerLastBooking(
      invoiceNo: int.tryParse(json['invoice_no']?.toString() ?? '0') ?? 0,
      customerId: int.tryParse(json['customer_id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      bookingTime: json['booking_time']?.toString() ?? '',
      totalItems: int.tryParse(json['total_items']?.toString() ?? '0') ?? rawItems.length,
      totalQty: int.tryParse(json['total_qty']?.toString() ?? '0') ?? 0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0.0') ?? 0.0,
      items: rawItems
          .map((e) => CustomerLastBookingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_no': invoiceNo,
      'customer_id': customerId,
      'customer_name': customerName,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'total_items': totalItems,
      'total_qty': totalQty,
      'grand_total': grandTotal,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerLastBookingItem {
  final String prodId;
  final String prodName;
  final String packSize;
  final int qty;
  final double bonus;
  final double price;
  final double discount;
  final double lineTotal;

  CustomerLastBookingItem({
    required this.prodId,
    required this.prodName,
    required this.packSize,
    required this.qty,
    required this.bonus,
    required this.price,
    required this.discount,
    required this.lineTotal,
  });

  factory CustomerLastBookingItem.fromJson(Map<String, dynamic> json) {
    return CustomerLastBookingItem(
      prodId: json['prod_id']?.toString() ?? '',
      prodName: json['prod_name']?.toString() ?? '',
      packSize: json['pack_size']?.toString() ?? '',
      qty: int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      bonus: double.tryParse(json['bonus']?.toString() ?? '0.0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0,
      lineTotal: double.tryParse(json['line_total']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prod_id': prodId,
      'prod_name': prodName,
      'pack_size': packSize,
      'qty': qty,
      'bonus': bonus,
      'price': price,
      'discount': discount,
      'line_total': lineTotal,
    };
  }
}
