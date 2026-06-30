
// lib/managers/legal_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class LegalManager {
  // Private constructor for Singleton pattern
  LegalManager._internal();

  // The single, shared instance of this class
  static final LegalManager instance = LegalManager._internal();

  SharedPreferences? _prefs;
  bool _hasAcceptedTerms = false;

  // Key used to store the boolean value locally on the device
  static const String _termsKey = 'has_accepted_terms_of_service';

  /// Initializes SharedPreferences and loads the cached status.
  /// Call this in your main.dart or initialization flow.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasAcceptedTerms = _prefs?.getBool(_termsKey) ?? false;
  }

  /// Public getter to check if the user has accepted the terms.
  bool get hasAcceptedTerms => _hasAcceptedTerms;

  /// Updates the acceptance state locally and saves it to persistent storage.
  Future<void> setTermsAccepted(bool accepted) async {
    _hasAcceptedTerms = accepted;
    if (_prefs != null) {
      await _prefs!.setBool(_termsKey, accepted);
    }
  }
}