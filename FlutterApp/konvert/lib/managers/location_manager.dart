import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/error_struct.dart';
import 'error_manager.dart';

class LocationManager extends ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  static LocationManager get instance => _instance;

  LocationManager._internal();

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  Future<void> init() async {
    // Optionally fetch location immediately on startup
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'LOC-DISABLED', technicalDetails: 'Location services are disabled. Please enable them to use the app.'),
        3,
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ErrorManager.instance.showToastError(
          ErrorStruct(code: 'LOC-DENIED', technicalDetails: 'Location permissions are denied.'),
          3,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'LOC-DENIED-FOREVER', technicalDetails: 'Location permissions are permanently denied, we cannot request permissions.'),
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

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e, stack) {
      ErrorManager.instance.logErrorToConsole(
        'LOCATION_MANAGER',
        ErrorStruct(
          code: 'LOC-001',
          technicalDetails: e.toString(),
        ),
        stack,
      );
      ErrorManager.instance.showToastError(ErrorStruct(code: 'LOC-FAIL', technicalDetails: 'Failed to fetch location.'), 3);
    } finally {
      _isFetching = false;
      notifyListeners();
    }

    return _currentPosition;
  }
}
