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
          const ErrorStruct(code: 'API-002', technicalDetails: 'Missing domain or API key context.'),
          3,
        );
        return null;
      }

      final String domain = companyData['url']!;
      final cleanDomain = domain.endsWith('/') ? domain.substring(0, domain.length - 1) : domain;
      final Uri url = Uri.parse('$cleanDomain/esalesmanAPI/checkuser.php');

      final response = await http.post(
        url,
        body: {
          "username": username,
          "password": password,
          "apiKey": apiKey,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          // Parse the JSON into our User model
          return User.fromJson(jsonResponse, username);
        } catch (e) {
          debugPrint('JSON Parsing failed. Server responded: ${response.body}');
          ErrorManager.instance.showToastError(
            const ErrorStruct(code: 'API-003', technicalDetails: 'Invalid credentials or server error.'),
            4,
          );
          return null;
        }
      } else {
        debugPrint('Server returned status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'API-004', technicalDetails: 'Network request failed: $e'),
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
          
      final Uri url = Uri.parse('$cleanDomain/esalesmanAPI/authenticateAPI.php');

      // Standard form-urlencoded POST request matching your Java map structure
      final response = await http.post(
        url,
        body: {
          "domain": domain,
          "apiKey": apiKey,
        },
      ).timeout(const Duration(seconds: 15)); // Prevent infinite hanging

      if (response.statusCode == 200) {
        // Evaluate the raw string response
        if (response.body.trim().toLowerCase() == 'success') {
          return true;
        } else {
          debugPrint('Authentication failed. Server responded: ${response.body}');
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
          technicalDetails: 'Network request failed: $e'
        ),
        4,
      );
      return false;
    }
  }
}