// lib/screens/domain_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../managers/app_manager.dart';
import '../models/domain.dart';
import 'user_type_selection_screen.dart';

class DomainSelectionScreen extends StatefulWidget {
  const DomainSelectionScreen({super.key});

  @override
  State<DomainSelectionScreen> createState() => _DomainSelectionScreenState();
}

class _DomainSelectionScreenState extends State<DomainSelectionScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  Domain? _selectedDomain;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Canvas Layer
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/domainBG.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Structural Content Layer
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Fixed Top Branding Logo Grouping
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Image.asset(
                            'assets/branding/Logomark_White.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        // Dynamic Spacer pushing everything else cleanly to the bottom
                        const Spacer(),

                        // 2. Heading Section (Positioned right above input boxes)
                        const Text(
                          'Domain',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Connect to your organization',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3. Input Form Fields Grouping (Positioned right above connect button)
                        Column(
                          children: [
                            // Custom Domain Dropdown Field Component
                            GestureDetector(
                              onTap: () => _showDomainSelectionDialog(context, appManager),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDomain?.name ?? 'Select Domain',
                                      style: TextStyle(
                                        color: _selectedDomain == null ? Colors.white60 : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Custom API Key Text Entry Field Component
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _apiKeyController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                onChanged: (val) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText: 'Enter API',
                                  hintStyle: TextStyle(color: Colors.white60, fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  errorBorder: InputBorder.none
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // 4. Primary CTA Button & Bottom Actions
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading || _selectedDomain == null || _apiKeyController.text.trim().isEmpty
                                    ? null
                                    : () => _handleConnect(context, appManager),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.white.withOpacity(0.25),
                                  disabledForegroundColor: Colors.white38,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                                      )
                                    : const Text(
                                        'Connect',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => _showHelpBottomSheet(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                                child: const Text(
                                  'Need Help?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Connection Tips', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                '1. Select your company domain\n'
                '2. Enter your API key\n'
                '3. Connect\n\n'
                'Your API key is provided securely by your organization.',
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDomainSelectionDialog(BuildContext context, AppManager appManager) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24, 
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Company', 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: appManager.domainList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final domain = appManager.domainList[index];
                    final isSelected = _selectedDomain == domain;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      tileColor: isSelected ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02),
                      title: Text(
                        domain.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22)
                          : Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 22),
                      onTap: () {
                        setState(() => _selectedDomain = domain);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleConnect(BuildContext context, AppManager appManager) async {
    final domain = _selectedDomain!;
    final apiKey = _apiKeyController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final url = '${domain.url}/esalesmanAPI/authenticateAPI.php';
      
      final response = await http.post(
        Uri.parse(url),
        body: {
          'apiKey': apiKey,
          'domain': domain.url,
        },
      ).timeout(const Duration(seconds: 10));
      
      final responseString = response.body.trim();
      
      if (responseString.toLowerCase() == 'success') {
        // Update the domain with the API key
        final updatedDomain = domain.copyWith(apiKey: apiKey);
        appManager.selectedDomain = updatedDomain;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication successful!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UserTypeSelectionScreen(),
            ),
          );
        }
      } else {
        await _showErrorDialog(context, responseString);
        setState(() {
          _selectedDomain = null;
          _apiKeyController.clear();
        });
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _selectedDomain = null;
        _apiKeyController.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String responseString) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Authentication Failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Server response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    responseString,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please check your API key and try again.',
                  style: TextStyle(fontSize: 14),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}