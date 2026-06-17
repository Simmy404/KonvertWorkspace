// lib/screens/terms_of_service_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/app_manager.dart';
import 'domain_selection_screen.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _canAgree = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final isAtBottom = currentScroll >= maxScroll - 15;
      if (isAtBottom != _canAgree) {
        setState(() {
          _canAgree = isAtBottom;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Go back to welcome screen cleanly
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image covering the entire screen
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/welcomeBG.png',
                fit: BoxFit.cover,
              ),
            ),

            // Main Content Layer
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top-left branded logomark
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.asset(
                        'assets/branding/Logomark_White.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Page Title
                    const Text(
                      'Terms of\nServices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Terms White Box Panel
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'All terms of services are written here',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ..._buildTermsList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full pill-shaped CTA Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canAgree ? _handleAgree : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white.withOpacity(0.3),
                          disabledForegroundColor: Colors.black38,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _canAgree ? 'I agree' : 'Scroll down to accept',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTermsList() {
    return [
      _buildTermSection(
        '1. Acceptance of Terms',
        'By using this application, you agree to be bound by these terms and conditions. If you do not agree, please do not use the application.',
      ),
      const SizedBox(height: 16),
      _buildTermSection(
        '2. User Accounts',
        'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.',
      ),
      const SizedBox(height: 16),
      _buildTermSection(
        '3. Data Privacy',
        'We collect and process your data in accordance with our Privacy Policy. By using this application, you consent to such collection and processing.',
      ),
      const SizedBox(height: 16),
      _buildTermSection(
        '4. Acceptable Use',
        'You agree to use this application only for lawful purposes and in a way that does not infringe on the rights of others.',
      ),
    ];
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAgree() {
    final appManager = Provider.of<AppManager>(context, listen: false);
    appManager.tosChecked = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DomainSelectionScreen(),
      ),
    );
  }
}