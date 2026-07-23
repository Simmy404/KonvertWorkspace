import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/booking_data.dart';
import '../../models/place_order_product.dart';
import '../../managers/location_manager.dart';

class PlaceOrderState extends ChangeNotifier {
  int currentStep = 0; // 0 = Bricks, 1 = Customers, 2 = Products
  Map<String, dynamic>? selectedBrick;
  Map<String, dynamic>? selectedCustomer;

  List<Map<String, dynamic>> allBricks = [];
  List<Map<String, dynamic>> filteredBricks = [];

  List<Map<String, dynamic>> allCustomers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  Map<String, int> brickCustomerCounts = {};

  List<PlaceOrderProduct> cart = [];
  String remarks = "";

  bool isLoading = false;

  TextEditingController brickSearchController = TextEditingController();
  TextEditingController customerSearchController = TextEditingController();
  TextEditingController productSearchController = TextEditingController();

  PlaceOrderState() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    // Fetch database data immediately
    final rawBricks = await DatabaseService.instance.getAllBricks();
    allBricks = List<Map<String, dynamic>>.from(rawBricks);
    allBricks.insert(0, {'brick_id': '0', 'brick_name': 'All Bricks'});
    filteredBricks = List.from(allBricks);

    final rawProducts = await DatabaseService.instance.getAllProducts();
    allProducts = List<Map<String, dynamic>>.from(rawProducts);
    filteredProducts = List.from(allProducts);

    // Compute customer counts per brick
    final rawAllCustomers = await DatabaseService.instance.getAllCustomers();
    brickCustomerCounts.clear();
    int totalCustomers = 0;
    for (var c in rawAllCustomers) {
      final bId = c['customer_brickid']?.toString() ?? '';
      if (bId.isNotEmpty) {
        brickCustomerCounts[bId] = (brickCustomerCounts[bId] ?? 0) + 1;
        totalCustomers++;
      }
    }
    brickCustomerCounts['0'] = totalCustomers;

    isLoading = false;
    notifyListeners();

    // Fetch location in background using LocationManager
    await LocationManager.instance.fetchCurrentLocation();
    notifyListeners(); // to update UI if LocationManager.instance.currentPosition changes
  }

  int getCustomerCountForBrick(String brickId) {
    return brickCustomerCounts[brickId] ?? 0;
  }

  void filterBricks(String query) {
    if (query.isEmpty) {
      filteredBricks = List.from(allBricks);
    } else {
      filteredBricks = allBricks.where((b) {
        final name = b['brick_name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> selectBrick(Map<String, dynamic> brick) async {
    selectedBrick = brick;
    currentStep = 1;
    customerSearchController.clear();
    notifyListeners();

    if (brick['brick_id'] == '0' || brick['brick_id'] == 0) {
      allCustomers = List<Map<String, dynamic>>.from(
        await DatabaseService.instance.getAllCustomers(),
      );
    } else {
      allCustomers = List<Map<String, dynamic>>.from(
        await DatabaseService.instance.getCustomersByBrickId(
          brick['brick_id'].toString(),
        ),
      );
    }

    filteredCustomers = List.from(allCustomers);
    notifyListeners();
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomers = List.from(allCustomers);
    } else {
      filteredCustomers = allCustomers.where((c) {
        final name = c['customer_name'].toString().toLowerCase();
        final type = c['customer_type'].toString().toLowerCase();
        final address = c['customer_address'].toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || type.contains(q) || address.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void selectCustomer(Map<String, dynamic> customer) {
    selectedCustomer = customer;
    currentStep = 2;
    productSearchController.clear();
    notifyListeners();
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((p) {
        final name = p['product_name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void addToCart(PlaceOrderProduct product) {
    final existingIndex = cart.indexWhere((p) => p.prodID == product.prodID);
    if (existingIndex >= 0) {
      cart[existingIndex] = product;
    } else {
      cart.add(product);
    }
    notifyListeners();
  }

  void removeFromCart(String prodID) {
    cart.removeWhere((p) => p.prodID == prodID);
    notifyListeners();
  }

  double get cartGrandTotal {
    return cart.fold(0.0, (sum, item) => sum + item.getGrandTotal());
  }

  void goBack() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  Future<bool> confirmOrder() async {
    if (cart.isEmpty || selectedCustomer == null || selectedBrick == null) {
      return false;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    final seconds = (timestamp / 1000).floor();
    final invoiceNo = (seconds * 1000) + random;

    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    for (var product in cart) {
      final b = BookingData(
        bookingInvoice: invoiceNo,
        bookingBrikId: int.tryParse(selectedBrick!['brick_id'].toString()) ?? 0,
        bookingCustId:
            int.tryParse(selectedCustomer!['customer_id'].toString()) ?? 0,
        bookingProdId: int.tryParse(product.prodID) ?? 0,
        bookingQty: product.qty,
        bookingBonus: product.bonus,
        bookingDiscount: product.discount,
        bookingPrice: product.price,
        bookingLong: LocationManager.instance.currentPosition?.longitude ?? 0.0,
        bookingLat: LocationManager.instance.currentPosition?.latitude ?? 0.0,
        bookingDate: dateStr,
        bookingTime: timeStr,
        bookingProdCount: cart.length,
        bookingRemarks: remarks,
      );
      await DatabaseService.instance.insertBooking(b);
    }

    return true;
  }
}
