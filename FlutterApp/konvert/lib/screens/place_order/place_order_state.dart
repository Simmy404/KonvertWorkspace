import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/api_service.dart';
import '../../models/booking_data.dart';
import '../../models/place_order_product.dart';
import '../../managers/location_manager.dart';

class PlaceOrderState extends ChangeNotifier {
  bool _isDisposed = false;
  final List<BookingData>? existingInvoiceItems;
  int? editingInvoiceNumber;

  int currentStep = 0; // 0 = Bricks, 1 = Customers, 2 = Products
  Map<String, dynamic>? selectedBrick;
  Map<String, dynamic>? selectedCustomer;

  List<Map<String, dynamic>> allBricks = [];
  List<Map<String, dynamic>> filteredBricks = [];
  bool isRefreshingBricks = false;

  List<Map<String, dynamic>> allCustomers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  String selectedCustomerTypeFilter = 'all'; // 'all', 'chemist', 'doctor'
  bool isRefreshingCustomers = false;

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  String selectedProductCategoryFilter = 'all'; // 'all', 'otc', 'rx'
  bool isRefreshingProducts = false;

  Map<String, int> brickCustomerCounts = {};

  List<PlaceOrderProduct> cart = [];
  String remarks = "";

  bool isLoading = false;

  TextEditingController brickSearchController = TextEditingController();
  TextEditingController customerSearchController = TextEditingController();
  TextEditingController productSearchController = TextEditingController();

  PlaceOrderState({this.existingInvoiceItems}) {
    _init();
  }

  @override
  void dispose() {
    _isDisposed = true;
    brickSearchController.dispose();
    customerSearchController.dispose();
    productSearchController.dispose();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _init() async {
    isLoading = true;
    _safeNotifyListeners();

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

    // Handle Edit Mode Pre-population if existingInvoiceItems is provided
    if (existingInvoiceItems != null && existingInvoiceItems!.isNotEmpty) {
      final firstItem = existingInvoiceItems!.first;
      editingInvoiceNumber = firstItem.bookingInvoice;
      remarks = firstItem.bookingRemarks;

      final bIdStr = firstItem.bookingBrikId.toString();
      final cIdStr = firstItem.bookingCustId.toString();

      // Find matching brick
      selectedBrick = allBricks.firstWhere(
        (b) => b['brick_id'].toString() == bIdStr,
        orElse: () => {'brick_id': bIdStr, 'brick_name': 'Brick #$bIdStr'},
      );

      // Load customers for that brick
      if (bIdStr == '0') {
        allCustomers = List<Map<String, dynamic>>.from(rawAllCustomers);
      } else {
        allCustomers = List<Map<String, dynamic>>.from(
          await DatabaseService.instance.getCustomersByBrickId(bIdStr),
        );
      }
      filteredCustomers = List.from(allCustomers);

      // Find matching customer
      selectedCustomer = allCustomers.firstWhere(
        (c) => c['customer_id'].toString() == cIdStr,
        orElse: () => {'customer_id': cIdStr, 'customer_name': 'Customer #$cIdStr'},
      );

      // Populate cart with existing items
      cart.clear();
      for (var item in existingInvoiceItems!) {
        final pIdStr = item.bookingProdId.toString();
        final matchedProd = allProducts.firstWhere(
          (p) => p['product_id'].toString() == pIdStr,
          orElse: () => {'product_name': 'Product #$pIdStr'},
        );

        cart.add(
          PlaceOrderProduct(
            prodID: pIdStr,
            name: matchedProd['product_name'] ?? 'Product #$pIdStr',
            qty: item.bookingQty,
            price: item.bookingPrice,
            discount: item.bookingDiscount,
            bonus: item.bookingBonus,
          ),
        );
      }

      // Jump directly to Step 2 (Product Step) for editing
      currentStep = 2;
    }

    isLoading = false;
    _safeNotifyListeners();

    // Fetch location in background using LocationManager
    await LocationManager.instance.fetchCurrentLocation();
    _safeNotifyListeners();
  }

  // --- REFRESH MODULES ---

  Future<void> refreshBricks() async {
    if (isRefreshingBricks) return;
    isRefreshingBricks = true;
    _safeNotifyListeners();

    try {
      await ApiService.instance.syncBricks();
      final rawBricks = await DatabaseService.instance.getAllBricks();
      allBricks = List<Map<String, dynamic>>.from(rawBricks);
      allBricks.insert(0, {'brick_id': '0', 'brick_name': 'All Bricks'});
      filterBricks(brickSearchController.text);
    } catch (e) {
      debugPrint('Error refreshing bricks: $e');
    } finally {
      isRefreshingBricks = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refreshCustomers() async {
    if (isRefreshingCustomers) return;
    isRefreshingCustomers = true;
    _safeNotifyListeners();

    try {
      await ApiService.instance.syncCustomers();
      if (selectedBrick != null) {
        final bIdStr = selectedBrick!['brick_id'].toString();
        if (bIdStr == '0') {
          allCustomers = List<Map<String, dynamic>>.from(
            await DatabaseService.instance.getAllCustomers(),
          );
        } else {
          allCustomers = List<Map<String, dynamic>>.from(
            await DatabaseService.instance.getCustomersByBrickId(bIdStr),
          );
        }
      } else {
        allCustomers = List<Map<String, dynamic>>.from(
          await DatabaseService.instance.getAllCustomers(),
        );
      }
      _applyCustomerFilters();
    } catch (e) {
      debugPrint('Error refreshing customers: $e');
    } finally {
      isRefreshingCustomers = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    if (isRefreshingProducts) return;
    isRefreshingProducts = true;
    _safeNotifyListeners();

    try {
      await ApiService.instance.syncProducts();
      final rawProducts = await DatabaseService.instance.getAllProducts();
      allProducts = List<Map<String, dynamic>>.from(rawProducts);
      _applyProductFilters();
    } catch (e) {
      debugPrint('Error refreshing products: $e');
    } finally {
      isRefreshingProducts = false;
      _safeNotifyListeners();
    }
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
    _safeNotifyListeners();
  }

  Future<void> selectBrick(Map<String, dynamic> brick) async {
    if (isRefreshingBricks) return; // Prevent selection while refreshing
    selectedBrick = brick;
    currentStep = 1;
    customerSearchController.clear();
    selectedCustomerTypeFilter = 'all';
    _safeNotifyListeners();

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

    _applyCustomerFilters();
  }

  void filterCustomers(String query) {
    _applyCustomerFilters();
  }

  void filterCustomersByType(String type) {
    selectedCustomerTypeFilter = type;
    _applyCustomerFilters();
  }

  void _applyCustomerFilters() {
    final query = customerSearchController.text.trim().toLowerCase();
    filteredCustomers = allCustomers.where((c) {
      final name = c['customer_name'].toString().toLowerCase();
      final type = c['customer_type'].toString().toLowerCase();
      final address = c['customer_address'].toString().toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          type.contains(query) ||
          address.contains(query);

      bool matchesType = true;
      if (selectedCustomerTypeFilter == 'doctor') {
        matchesType = type.contains('doctor') || type == '2';
      } else if (selectedCustomerTypeFilter == 'chemist') {
        matchesType = !type.contains('doctor') && type != '2';
      }

      return matchesQuery && matchesType;
    }).toList();
    _safeNotifyListeners();
  }

  void selectCustomer(Map<String, dynamic> customer) {
    if (isRefreshingCustomers) return; // Prevent selection while refreshing
    selectedCustomer = customer;
    currentStep = 2;
    productSearchController.clear();
    selectedProductCategoryFilter = 'all';
    _safeNotifyListeners();
  }

  void filterProducts(String query) {
    _applyProductFilters();
  }

  void filterProductsByCategory(String category) {
    selectedProductCategoryFilter = category;
    _applyProductFilters();
  }

  void _applyProductFilters() {
    final query = productSearchController.text.trim().toLowerCase();
    filteredProducts = allProducts.where((p) {
      final name = p['product_name'].toString().toLowerCase();
      final isOtc = p['product_is_otc'] != null &&
          p['product_is_otc'].toString().trim().isNotEmpty;

      final matchesQuery = query.isEmpty || name.contains(query);

      bool matchesCategory = true;
      if (selectedProductCategoryFilter == 'otc') {
        matchesCategory = isOtc;
      } else if (selectedProductCategoryFilter == 'rx') {
        matchesCategory = !isOtc;
      }

      return matchesQuery && matchesCategory;
    }).toList();
    _safeNotifyListeners();
  }

  void incrementProductQty(Map<String, dynamic> product) {
    if (isRefreshingProducts) return;
    final prodId = product['product_id'].toString();
    final existingIndex = cart.indexWhere((p) => p.prodID == prodId);
    
    if (existingIndex >= 0) {
      cart[existingIndex].qty += 1;
    } else {
      final price = double.tryParse(product['product_tp'].toString()) ?? 0.0;
      cart.add(PlaceOrderProduct(
        prodID: prodId,
        name: product['product_name']?.toString() ?? 'Product',
        qty: 1,
        price: price,
      ));
    }
    _safeNotifyListeners();
  }

  void decrementProductQty(String prodId) {
    if (isRefreshingProducts) return;
    final existingIndex = cart.indexWhere((p) => p.prodID == prodId);
    if (existingIndex >= 0) {
      if (cart[existingIndex].qty > 1) {
        cart[existingIndex].qty -= 1;
      } else {
        cart.removeAt(existingIndex);
      }
      _safeNotifyListeners();
    }
  }

  void addToCart(PlaceOrderProduct product) {
    if (isRefreshingProducts) return;
    final existingIndex = cart.indexWhere((p) => p.prodID == product.prodID);
    if (existingIndex >= 0) {
      cart[existingIndex] = product;
    } else {
      cart.add(product);
    }
    _safeNotifyListeners();
  }

  void removeFromCart(String prodID) {
    if (isRefreshingProducts) return;
    cart.removeWhere((p) => p.prodID == prodID);
    _safeNotifyListeners();
  }

  double get cartGrandTotal {
    return cart.fold(0.0, (sum, item) => sum + item.getGrandTotal());
  }

  void jumpToStep(int step) {
    if (step == 0) {
      currentStep = 0;
      _safeNotifyListeners();
    } else if (step == 1 && selectedBrick != null) {
      currentStep = 1;
      _safeNotifyListeners();
    } else if (step == 2 && selectedCustomer != null) {
      currentStep = 2;
      _safeNotifyListeners();
    }
  }

  void goBack() {
    if (currentStep > 0) {
      currentStep--;
      _safeNotifyListeners();
    }
  }

  Future<bool> confirmOrder() async {
    if (cart.isEmpty || selectedCustomer == null || selectedBrick == null) {
      return false;
    }

    final int invoiceNo;
    if (editingInvoiceNumber != null) {
      await DatabaseService.instance.deleteBookingByInvoice(editingInvoiceNumber.toString());
      invoiceNo = editingInvoiceNumber!;
    } else {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(1000);
      final seconds = (timestamp / 1000).floor();
      invoiceNo = (seconds * 1000) + random;
    }

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
