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
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isExpanded = false;
  String _searchQuery = '';

  // Pre-populated list matching your design mockups
  final List<Company> _companies = const [
    Company(name: 'Abott Enterprise', url: 'https://www.abott.com'),
    Company(name: 'Bristol Mayer Biotech', url: 'https://www.bristol.pk'),
    Company(name: 'Faisal Pharma', url: 'https://www.faisalpharma.com'),
    Company(name: 'Hassan Pharma', url: 'https://www.hassanpharma.com'),
  ];
  
  late Company _selectedCompany;

  @override
  void initState() {
    super.initState();
    _selectedCompany = _companies[1]; // Default to Bristol Mayer Biotech
    
    // Attach listener for real-time search filtering
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
          const ErrorStruct(code: 'DOM-001', technicalDetails: 'Could not launch URL'),
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
        const ErrorStruct(code: 'DOM-003', technicalDetails: 'API Key cannot be empty.'),
        3,
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Send the network request
    final bool isSuccess = await ApiService.instance.authenticateDomain(
      domain: _selectedCompany.url,
      apiKey: apiKey,
    );

    if (!mounted) return;

    if (isSuccess) {
      // 2. Save company AND API key to local hardware storage
      await StorageService.instance.setCurrentCompany(
        name: _selectedCompany.name,
        url: _selectedCompany.url,
      );
      await StorageService.instance.setApiKey(apiKey);
      
      // 3. Transition to Login Screen
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeSlideUpTransition(const LoginScreen()), 
      );
    } else {
      ErrorManager.instance.showToastError(
        const ErrorStruct(code: 'DOM-004', technicalDetails: 'Invalid API Key or Domain.'),
        4,
      );
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Colors.black),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), 
                  
                  Image.asset(
                    ThemeManager.instance.getLogoMark(), 
                    width: 42,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image, 
                      color: Colors.white, 
                      size: 32
                    ),
                  ),
                  
                  // This Expanded widget smartly swaps the top UI without moving the bottom fields
                  Expanded(
                    child: _isExpanded 
                        ? _buildExpandedSelector()
                        : _buildCollapsedView(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildApiKeyField(),
                  
                  const SizedBox(height: 24),
                  
                  // Confirm Button with Loading State
                  SizedBox(
                    width: double.infinity,
                    height: 64, 
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onConfirm, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance.getPrimaryColor(),
                        foregroundColor: ThemeManager.instance.getContrastColor(),
                        disabledBackgroundColor: ThemeManager.instance.getPrimaryColor().withOpacity(0.5),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(
                              color: ThemeManager.instance.getContrastColor(), 
                              strokeWidth: 3
                            )
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: -0.3
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Center(
                    child: TextButton(
                      onPressed: _launchHelpUrl, 
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), 
                      ),
                      child: Text(
                        'Need Help?',
                        style: TextStyle(
                          color: ThemeManager.instance.getMatchColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2
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

  // --- SUB-WIDGET: The normal, unexpanded view ---
  Widget _buildCollapsedView() {
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
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
              color: ThemeManager.instance.getMatchColor(),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 0),
        Center(
          child: Text(
            'Select your company and enter key',
            style: TextStyle(
              color: ThemeManager.instance.getGreyTransparent5(),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildCompanySelector(isExpanded: false),
      ],
    );
  }

  // --- SUB-WIDGET: The fully expanded search panel ---
  Widget _buildExpandedSelector() {
    final filteredCompanies = _companies.where((c) {
      return c.name.toLowerCase().contains(_searchQuery) || 
             c.url.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 0),
      decoration: BoxDecoration(
        color: ThemeManager.instance.getGreyTransparent1(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeManager.instance.getGreyTransparent3(),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 1. Pill-shaped Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeManager.instance.getGreyTransparent1(),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ThemeManager.instance.getGreyTransparent3(),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: ThemeManager.instance.getGreyTransparent5(), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: ThemeManager.instance.getMatchColor(), fontSize: 15),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Company',
                        hintStyle: TextStyle(color: ThemeManager.instance.getGreyTransparent5()),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Scrollable Company List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredCompanies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final company = filteredCompanies[index];
                final isSelected = company == _selectedCompany;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCompany = company;
                      _isExpanded = false;
                      _searchController.clear(); // Reset search when collapsing
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: ThemeManager.instance.getGreyTransparent1(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? ThemeManager.instance.getPrimaryColor() 
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: TextStyle(
                            color: ThemeManager.instance.getMatchColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          company.url,
                          style: TextStyle(
                            color: ThemeManager.instance.getGreyTransparent5(),
                            fontSize: 13,
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
          
          // 3. Anchor Bottom Toggle
          _buildCompanySelector(isExpanded: true),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: The anchor toggle used in both states ---
  Widget _buildCompanySelector({required bool isExpanded}) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (!_isExpanded) _searchController.clear();
        });
      },
      borderRadius: isExpanded 
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeManager.instance.getGreyTransparent1(),
          borderRadius: isExpanded 
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.circular(16),
          border: isExpanded ? null : Border.all(
            color: ThemeManager.instance.getGreyTransparent3(),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language, 
              color: ThemeManager.instance.getGreyTransparent5(), 
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCompany.name,
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedCompany.url,
                    style: TextStyle(
                      color: ThemeManager.instance.getGreyTransparent5(),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
              color: ThemeManager.instance.getGreyTransparent5(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ThemeManager.instance.getGreyTransparent1(), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeManager.instance.getGreyTransparent3(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline, 
            color: ThemeManager.instance.getGreyTransparent5(), 
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              enabled: !_isLoading,
              style: TextStyle(
                color: ThemeManager.instance.getPrimaryColor(), 
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter API Key',
                hintStyle: TextStyle(
                  color: ThemeManager.instance.getGreyTransparent5(), 
                  fontSize: 15,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}