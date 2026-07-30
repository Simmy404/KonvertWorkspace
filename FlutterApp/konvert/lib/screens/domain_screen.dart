// lib/screens/domain_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
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
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController(
    text: '28',
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _domainController.dispose();
    _apiKeyController.dispose();
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
    final rawDomain = _domainController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (rawDomain.isEmpty) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'DOM-003',
          technicalDetails: 'Domain cannot be empty.',
        ),
        3,
      );
      return;
    }

    if (apiKey.isEmpty) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'DOM-005',
          technicalDetails: 'API Key cannot be empty.',
        ),
        3,
      );
      return;
    }

    // Normalise: ensure the domain starts with http:// or https://
    String domain = rawDomain;
    if (!domain.startsWith('http://') && !domain.startsWith('https://')) {
      domain = 'https://$domain';
    }

    setState(() => _isLoading = true);

    final bool isSuccess = await ApiService.instance.authenticateDomain(
      domain: domain,
      apiKey: apiKey,
    );

    if (!mounted) return;

    if (isSuccess) {
      // Derive a friendly display name from the domain host
      final uri = Uri.tryParse(domain);
      final displayName = uri?.host ?? rawDomain;

      await StorageService.instance.setCurrentCompany(
        name: displayName,
        url: domain,
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

    // Theme Color Tokens
    final Color bgColor =
        isLight ? const Color(0xFFF7F8FC) : const Color(0xFF03071A);

    final Color inputBg =
        isLight ? const Color(0xFFF1F0F3) : const Color(0xFF131520);
    final Color inputBorder =
        isLight ? const Color(0xFFE3E1E5) : const Color(0xFF242634);
    final Color inputIconColor = const Color(0xFF8E8E93);
    final Color inputHintColor = const Color(0xFF8E8E93);
    final Color searchTextColor = isLight ? const Color(0xFF1C1C1E) : Colors.white;

    final Color buttonBg = isLight ? const Color(0xFF0038FF) : Colors.white;
    final Color buttonTextColor = isLight ? Colors.white : Colors.black;
    final String buttonText = isLight ? 'Connect' : 'Confirm';

    final Color helpTextColor = isLight ? Colors.black : Colors.white;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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

                    // Hero image + title (flexible, fills available space)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Image.asset(
                                  ThemeManager.instance.getDomainMain(),
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                    Icons.language,
                                    color: isLight
                                        ? Colors.blue.shade300
                                        : Colors.white54,
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
                              'Enter your server domain and API key',
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
                        ],
                      ),
                    ),

                    // Domain Text Input
                    _buildInputField(
                      controller: _domainController,
                      icon: Icons.language,
                      hint: 'e.g. yourdomain.com',
                      label: 'Server Domain',
                      inputBg: inputBg,
                      inputBorder: inputBorder,
                      inputIconColor: inputIconColor,
                      inputHintColor: inputHintColor,
                      textColor: searchTextColor,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 12),

                    // API Key Field
                    _buildInputField(
                      controller: _apiKeyController,
                      icon: Icons.lock_outline,
                      hint: 'Enter API Key',
                      label: 'API Key',
                      obscureText: true,
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required String label,
    required Color inputBg,
    required Color inputBorder,
    required Color inputIconColor,
    required Color inputHintColor,
    required Color textColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
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
          Icon(icon, color: inputIconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              enabled: !_isLoading,
              keyboardType: keyboardType,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
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
