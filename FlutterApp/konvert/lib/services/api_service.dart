// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/storage_service.dart';

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Authenticates the user against the currently saved domain
  Future<User?> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      final companyData = StorageService.instance.getCurrentCompany();
      final apiKey = StorageService.instance.getApiKey();

      if (companyData == null || apiKey == null) {
        ErrorManager.instance.showToastError(
          const ErrorStruct(
            code: 'API-002',
            technicalDetails: 'Missing domain or API key context.',
          ),
          3,
        );
        return null;
      }

      final String domain = companyData['url']!;
      final cleanDomain = domain.endsWith('/')
          ? domain.substring(0, domain.length - 1)
          : domain;
      final Uri url = Uri.parse('$cleanDomain/esalesmanAPI/checkuser.php');

      final response = await http
          .post(
            url,
            body: {
              "username": username,
              "password": password,
              "apiKey": apiKey,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          // 1. Try parsing as JSON first (Success case)
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return User.fromJson(jsonResponse, username);
        } catch (e) {
          // 2. If JSON parsing fails, PHP script returned plain-text error message
          debugPrint('Server rejected login: ${response.body}');
          ErrorManager.instance.showToastError(
            ErrorStruct(
              code: 'AUTH-REJECTED',
              technicalDetails: response.body.trim(),
            ),
            4,
          );
          return null;
        }
      } else {
        debugPrint('Server returned status code: ${response.statusCode}');
        ErrorManager.instance.showToastError(
          ErrorStruct(
            code: 'API-003',
            technicalDetails: 'Server error: ${response.statusCode}',
          ),
          3,
        );
        return null;
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'API-004',
          technicalDetails: 'Network request failed: $e',
        ),
        4,
      );
      return null;
    }
  }

  /// Authenticates the given domain and API key against the server
  Future<bool> authenticateDomain({
    required String domain,
    required String apiKey,
  }) async {
    try {
      // Clean the URL to prevent double slashes
      final cleanDomain = domain.endsWith('/')
          ? domain.substring(0, domain.length - 1)
          : domain;

      final Uri url = Uri.parse(
        '$cleanDomain/esalesmanAPI/authenticateAPI.php',
      );

      // Standard form-urlencoded POST request matching your Java map structure
      final response = await http
          .post(url, body: {"domain": domain, "apiKey": apiKey})
          .timeout(const Duration(seconds: 15)); // Prevent infinite hanging

      if (response.statusCode == 200) {
        final bodyStr = response.body.trim().toLowerCase();
        // Evaluate raw string response from PHP script ('success')
        if (bodyStr == 'success' || bodyStr.contains('success')) {
          return true;
        } else {
          debugPrint(
            'Authentication failed. Server responded: ${response.body}',
          );
          return false;
        }
      } else {
        debugPrint('Server returned status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'API-001',
          technicalDetails: 'Network request failed: $e',
        ),
        4,
      );
      return false;
    }
  }

  // Generic POST wrapper for sync requests
  Future<Map<String, dynamic>?> _postSyncRequest(String endpoint) async {
    final company = StorageService.instance.getCurrentCompany();
    final user = StorageService.instance.getCurrentUser();

    if (company == null || user == null) return null;

    String domain = company['url']!;
    if (!domain.startsWith('http://') && !domain.startsWith('https://')) {
      domain = 'https://$domain';
    }
    final cleanDomain = domain.endsWith('/')
        ? domain.substring(0, domain.length - 1)
        : domain;
    final Uri url = Uri.parse('$cleanDomain/esalesmanAPI/$endpoint');

    try {
      final response = await http
          .post(
            url,
            body: {"userid": user.id.toString(), "bid": user.bid.toString()},
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          debugPrint('Sync Error ($endpoint): Expected JSON object response');
          return null;
        }
      } else {
        debugPrint('Sync Error ($endpoint): Status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Sync Exception ($endpoint): $e');
      return null;
    }
  }

  // --- INDIVIDUAL SYNC MODULES ---

  Future<bool> syncBricks() async {
    final data = await _postSyncRequest('getBricks.php');
    if (data != null) {
      final list = data['bricklist'];
      if (list != null && list is List) {
        await StorageService.instance.saveSyncBricks(list);
        return true;
      }
    }
    return false;
  }

  Future<bool> syncProducts() async {
    final data = await _postSyncRequest('getProducts.php');
    if (data != null) {
      // Backend returns 'productlist' (as in Utilities.java) or fallback 'prodlist'
      final list = data['productlist'] ?? data['prodlist'];
      if (list != null && list is List) {
        await StorageService.instance.saveSyncProducts(list);
        return true;
      }
    }
    return false;
  }

  Future<bool> syncCustomers() async {
    final data = await _postSyncRequest('getCustomers.php');
    if (data != null) {
      // Backend returns 'customerlist' (as in Utilities.java) or fallback 'custlist'
      final list = data['customerlist'] ?? data['custlist'];
      if (list != null && list is List) {
        await StorageService.instance.saveSyncCustomers(list);
        return true;
      }
    }
    return false;
  }

  Future<bool> syncTarget() async {
    final data = await _postSyncRequest('getTarget.php');
    if (data != null) {
      Map<String, dynamic>? targetMap;
      if (data.containsKey('targetlist') &&
          data['targetlist'] is List &&
          (data['targetlist'] as List).isNotEmpty) {
        targetMap = Map<String, dynamic>.from(data['targetlist'][0]);
      } else {
        targetMap = data;
      }
      await StorageService.instance.setTargets(
        monthTarget: targetMap['month_target']?.toString() ?? '0',
        totalSales: targetMap['total_sales']?.toString() ?? '0',
        todaySales: targetMap['today_sales']?.toString() ?? '0',
        noOfOrders: targetMap['no_of_orders']?.toString() ?? '0',
      );
      return true;
    }
    return false;
  }
}
