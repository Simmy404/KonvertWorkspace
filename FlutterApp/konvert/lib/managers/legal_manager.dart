import '../services/storage_service.dart';

class LegalManager {
  LegalManager._internal();
  static final LegalManager instance = LegalManager._internal();

  bool _hasAcceptedTerms = false;
  static const String _termsKey = 'has_accepted_terms_of_service';

  Future<void> init() async {
    // Read directly from the synchronous StorageService cache
    _hasAcceptedTerms = StorageService.instance.getBool(_termsKey) ?? false;
  }

  bool get hasAcceptedTerms => _hasAcceptedTerms;

  Future<void> setTermsAccepted(bool accepted) async {
    _hasAcceptedTerms = accepted;
    // Route write operations through the safe storage handler
    await StorageService.instance.setBool(_termsKey, accepted);
  }
}