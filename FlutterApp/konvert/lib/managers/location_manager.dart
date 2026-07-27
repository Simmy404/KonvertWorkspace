import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/error_struct.dart';
import '../services/storage_service.dart';
import 'error_manager.dart';

class LocationManager extends ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  static LocationManager get instance => _instance;

  LocationManager._internal();

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  StreamSubscription<Position>? _positionStreamSub;

  String get precision => StorageService.instance.getLocationPrecision();
  double get geofenceRadius => StorageService.instance.getGeofenceRadius();

  Future<void> setPrecision(String value) async {
    await StorageService.instance.setLocationPrecision(value);
    notifyListeners();
  }

  Future<void> setGeofenceRadius(double meters) async {
    await StorageService.instance.setGeofenceRadius(meters);
    notifyListeners();
  }

  void startLocationUpdates() async {
    if (_positionStreamSub != null) return;
    final hasPermission = await checkPermissions();
    if (!hasPermission) return;

    final accuracy = precision == 'high'
        ? LocationAccuracy.high
        : LocationAccuracy.medium;
    _positionStreamSub =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            distanceFilter: 3, // update every 3 meters
          ),
        ).listen(
          (Position pos) {
            _currentPosition = pos;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Location stream error: $e');
          },
        );
  }

  void stopLocationUpdates() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  /// Helper to safely parse and resolve customer coordinates, handling inverted lat/lng if needed.
  Map<String, double?> parseCustomerCoordinates(Map<String, dynamic> customer) {
    final val1 = double.tryParse(
      customer['customer_lat']?.toString() ??
          customer['cust_lat']?.toString() ??
          '',
    );
    final val2 = double.tryParse(
      customer['customer_long']?.toString() ??
          customer['customer_lng']?.toString() ??
          customer['cust_long']?.toString() ??
          '',
    );

    if (val1 == null && val2 == null) {
      return {'lat': null, 'lng': null};
    }

    if ((val1 == 0.0 && val2 == 0.0) || val1 == null || val2 == null) {
      return {
        'lat': (val1 == 0.0) ? null : val1,
        'lng': (val2 == 0.0) ? null : val2,
      };
    }

    // Invert swap protection: if val1 > val2 in magnitude (e.g., val1=73.08, val2=33.68),
    // val1 is longitude and val2 is latitude.
    if (val1.abs() > val2.abs() && val1.abs() > 45.0 && val2.abs() < 45.0) {
      return {'lat': val2, 'lng': val1};
    }

    return {'lat': val1, 'lng': val2};
  }

  /// Calculates distance in meters to target coordinates
  double? getDistanceTo(double? targetLat, double? targetLng) {
    if (_currentPosition == null || targetLat == null || targetLng == null)
      return null;
    if (targetLat == 0.0 && targetLng == 0.0) return null;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLat,
      targetLng,
    );
  }

  /// Checks if coordinates are within the configured geofence radius.
  /// If lat/long are not defined or invalid (0.0), enables customer by default.
  bool isLocationInGeofence(double? targetLat, double? targetLng) {
    if (targetLat == null || targetLng == null) return true;
    if (targetLat == 0.0 && targetLng == 0.0) return true;

    final distance = getDistanceTo(targetLat, targetLng);
    if (distance == null)
      return true; // Fallback to enabled if location not fetched yet
    return distance <= geofenceRadius;
  }

  Future<void> init() async {
    // Optionally fetch location immediately on startup
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'LOC-DISABLED',
          technicalDetails:
              'Location services are disabled. Please enable them to use the app.',
        ),
        3,
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ErrorManager.instance.showToastError(
          ErrorStruct(
            code: 'LOC-DENIED',
            technicalDetails: 'Location permissions are denied.',
          ),
          3,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'LOC-DENIED-FOREVER',
          technicalDetails:
              'Location permissions are permanently denied, we cannot request permissions.',
        ),
        3,
      );
      return false;
    }

    return true;
  }

  Future<Position?> fetchCurrentLocation({bool forceUpdate = false}) async {
    if (!forceUpdate && _currentPosition != null) {
      return _currentPosition;
    }

    if (_isFetching) return _currentPosition;

    _isFetching = true;
    notifyListeners();

    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        _isFetching = false;
        notifyListeners();
        return null;
      }

      final accuracy = precision == 'high'
          ? LocationAccuracy.high
          : LocationAccuracy.medium;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e, stack) {
      ErrorManager.instance.logErrorToConsole(
        'LOCATION_MANAGER',
        ErrorStruct(code: 'LOC-001', technicalDetails: e.toString()),
        stack,
      );
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'LOC-FAIL',
          technicalDetails: 'Failed to fetch location.',
        ),
        3,
      );
    } finally {
      _isFetching = false;
      notifyListeners();
    }

    return _currentPosition;
  }
}
