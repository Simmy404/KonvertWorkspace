// lib/screens/domain_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../models/company.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import '../utils/page_transitions.dart';

class DomainScreen extends StatefulWidget {
  const DomainScreen({super.key});

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  final TextEditingController _apiKeyController = TextEditingController(text: '28');
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isExpanded = false;
  String _searchQuery = '';

  final List<Company> _companies = const [
    Company(
      name: 'Abott Enterprise',
      url: 'https://www.abott.com',
      displayUrl: 'abott.com',
    ),
    Company(
      name: 'Bristol Mayer Biotech',
      url: 'https://www.hassanpharma.com',
      displayUrl: 'bristol.pk',
    ),
    Company(
      name: 'Faisal Pharma',
      url: 'https://www.faisalpharma.com',
      displayUrl: 'faisalpharma.com',
    ),
    Company(
      name: 'Hassan Pharma',
      url: 'https://www.hassanpharma.com',
      displayUrl: 'hassanpharma.com',
    ),
  ];

  late Company _selectedCompany;

  @override
  void initState() {
    super.initState();
    _selectedCompany = _companies[1]; // Default to Bristol Mayer Biotech

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ErrorManager.instance.showToastError(
          const ErrorStruct(
            code: 'DOM-001',
            technicalDetails: 'Could not launch URL',
          ),
          3,
        );
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'DOM-002', technicalDetails: e.toString()),
        3,
      );
    }
  }

  Future<void> _onConfirm() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'DOM-003',
          technicalDetails: 'API Key cannot be empty.',
        ),
        3,
      );
      return;
    }

    setState(() => _isLoading = true);

    final bool isSuccess = await ApiService.instance.authenticateDomain(
      domain: _selectedCompany.url,
      apiKey: apiKey,
    );

    if (!mounted) return;

    if (isSuccess) {
      await StorageService.instance.setCurrentCompany(
        name: _selectedCompany.name,
        url: _selectedCompany.url,
      );
      await StorageService.instance.setApiKey(apiKey);

      Navigator.pushReplacement(
        context,
        PageTransitions.fadeSlideUpTransition(const LoginScreen()),
      );
    } else {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'DOM-004',
          technicalDetails: 'Invalid API Key or Domain.',
        ),
        4,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = ThemeManager.instance.isLightMode;

    // Theme Color Tokens according to mockup:
    final Color bgColor = isLight
        ? const Color(0xFFF7F8FC)
        : const Color(0xFF03071A);
    final Color outerBoxBg = isLight
        ? const Color(0xFFF1F0F3)
        : const Color(0xFF131520);
    final Color outerBoxBorder = isLight
        ? const Color(0xFFE3E1E5)
        : const Color(0xFF242634);

    final Color searchBarBg = isLight ? Colors.white : const Color(0xFF262832);
    final Color searchBarBorder = isLight
        ? const Color(0xFFE5E4E8)
        : const Color(0xFF383A48);
    final Color searchIconColor = isLight
        ? const Color(0xFF7A7A80)
        : const Color(0xFF8E8E93);
    final Color searchTextColor = isLight
        ? const Color(0xFF1C1C1E)
        : Colors.white;

    final Color cardBg = isLight
        ? const Color(0xFFEEF3FF)
        : const Color(0xFF222432);
    final Color selectedCardBorder = const Color(
      0xFF9E8FFF,
    ); // Lavender / Indigo purple stroke
    final Color cardTitleColor = isLight
        ? const Color(0xFF1C1C1E)
        : Colors.white;
    final Color cardUrlColor = isLight
        ? const Color(0xFF6E6E73)
        : const Color(0xFF9A9AA4);

    final Color bottomHeaderBg = isLight
        ? const Color(0xFFEEF3FF)
        : const Color(0xFF151C30);
    final Color bottomHeaderBorder = isLight
        ? const Color(0xFFDCE2FF)
        : const Color(0xFF263354);

    final Color inputBg = isLight
        ? const Color(0xFFF1F0F3)
        : const Color(0xFF131520);
    final Color inputBorder = isLight
        ? const Color(0xFFE3E1E5)
        : const Color(0xFF242634);
    final Color inputIconColor = const Color(0xFF8E8E93);
    final Color inputHintColor = const Color(0xFF8E8E93);

    final Color buttonBg = isLight ? const Color(0xFF0038FF) : Colors.white;
    final Color buttonTextColor = isLight ? Colors.white : Colors.black;
    final String buttonText = isLight ? 'Connect' : 'Confirm';

    final Color helpTextColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: bgColor),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Brand Logo
                  Image.asset(
                    ThemeManager.instance.getLogoMark(),
                    width: 44,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.blur_on,
                      color: isLight ? Colors.blue : Colors.white,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main Domain Selection Container
                  Expanded(
                    child: _isExpanded
                        ? _buildExpandedSelector(
                            outerBoxBg: outerBoxBg,
                            outerBoxBorder: outerBoxBorder,
                            searchBarBg: searchBarBg,
                            searchBarBorder: searchBarBorder,
                            searchIconColor: searchIconColor,
                            searchTextColor: searchTextColor,
                            cardBg: cardBg,
                            selectedCardBorder: selectedCardBorder,
                            cardTitleColor: cardTitleColor,
                            cardUrlColor: cardUrlColor,
                            bottomHeaderBg: bottomHeaderBg,
                            bottomHeaderBorder: bottomHeaderBorder,
                          )
                        : _buildCollapsedView(
                            bottomHeaderBg: bottomHeaderBg,
                            bottomHeaderBorder: bottomHeaderBorder,
                            cardTitleColor: cardTitleColor,
                            cardUrlColor: cardUrlColor,
                            inputIconColor: inputIconColor,
                          ),
                  ),

                  const SizedBox(height: 16),

                  // API Key Field
                  _buildApiKeyField(
                    inputBg: inputBg,
                    inputBorder: inputBorder,
                    inputIconColor: inputIconColor,
                    inputHintColor: inputHintColor,
                    textColor: searchTextColor,
                  ),

                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBg,
                        foregroundColor: buttonTextColor,
                        disabledBackgroundColor: buttonBg.withOpacity(0.5),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: buttonTextColor,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                                color: buttonTextColor,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Need Help Link
                  Center(
                    child: TextButton(
                      onPressed: _launchHelpUrl,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        'Need Help?',
                        style: TextStyle(
                          color: helpTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: Collapsed View ---
  Widget _buildCollapsedView({
    required Color bottomHeaderBg,
    required Color bottomHeaderBorder,
    required Color cardTitleColor,
    required Color cardUrlColor,
    required Color inputIconColor,
  }) {
    final bool isLight = ThemeManager.instance.isLightMode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Image.asset(
                ThemeManager.instance.getDomainMain(),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.language,
                  color: isLight ? Colors.blue.shade300 : Colors.white54,
                  size: 100,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            'Connect Domain',
            style: TextStyle(
              color: isLight ? Colors.black : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Select your company and enter key',
            style: TextStyle(
              color: isLight
                  ? const Color(0xFF6E6E73)
                  : const Color(0xFF9A9AA4),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildCompanySelectorHeader(
          isExpanded: false,
          bgColor: bottomHeaderBg,
          borderColor: bottomHeaderBorder,
          titleColor: cardTitleColor,
          urlColor: cardUrlColor,
          iconColor: inputIconColor,
        ),
      ],
    );
  }

  // --- SUB-WIDGET: Fully Expanded Selector Panel ---
  Widget _buildExpandedSelector({
    required Color outerBoxBg,
    required Color outerBoxBorder,
    required Color searchBarBg,
    required Color searchBarBorder,
    required Color searchIconColor,
    required Color searchTextColor,
    required Color cardBg,
    required Color selectedCardBorder,
    required Color cardTitleColor,
    required Color cardUrlColor,
    required Color bottomHeaderBg,
    required Color bottomHeaderBorder,
  }) {
    final filteredCompanies = _companies.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.url.toLowerCase().contains(_searchQuery) ||
          c.displayUrl.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: outerBoxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outerBoxBorder, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1. Search Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: searchBarBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: searchBarBorder, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: searchIconColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: searchTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search company',
                      hintStyle: TextStyle(
                        color: searchIconColor,
                        fontSize: 16,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Company List Items
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredCompanies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final company = filteredCompanies[index];
                final isSelected = company.name == _selectedCompany.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCompany = company;
                      _isExpanded = false;
                      _searchController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: selectedCardBorder, width: 1.5)
                          : Border.all(color: Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: TextStyle(
                            color: cardTitleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          company.displayUrl,
                          style: TextStyle(
                            color: cardUrlColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. Bottom Selected Selector Trigger Header
          _buildCompanySelectorHeader(
            isExpanded: true,
            bgColor: bottomHeaderBg,
            borderColor: bottomHeaderBorder,
            titleColor: cardTitleColor,
            urlColor: cardUrlColor,
            iconColor: searchIconColor,
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: Domain Selector Header Bar ---
  Widget _buildCompanySelectorHeader({
    required bool isExpanded,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required Color urlColor,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCompany.name,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCompany.displayUrl,
                    style: TextStyle(color: urlColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: iconColor,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  // --- SUB-WIDGET: API Key Field ---
  Widget _buildApiKeyField({
    required Color inputBg,
    required Color inputBorder,
    required Color inputIconColor,
    required Color inputHintColor,
    required Color textColor,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: inputBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: inputIconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              enabled: !_isLoading,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter API Key',
                hintStyle: TextStyle(color: inputHintColor, fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
