// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/totp_service.dart';
import 'dashboard_screen.dart';
import 'domain_screen.dart';
import '../utils/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'huraira@hassanpharma.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'huraira123',
  );

  // 6-digit OTP Controllers & FocusNodes
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _obscurePassword = true;

  // TOTP stage control
  bool _isOtpStage = false;
  User? _pendingUser;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ErrorManager.instance.showToastError(
          const ErrorStruct(
            code: 'LOG-001',
            technicalDetails: 'Could not launch URL',
          ),
          3,
        );
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'LOG-002', technicalDetails: e.toString()),
        3,
      );
    }
  }

  Future<void> _onLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'LOG-003',
          technicalDetails: 'Fields cannot be empty.',
        ),
        3,
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Authenticate user against API
    final User? authenticatedUser = await ApiService.instance.authenticateUser(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (authenticatedUser != null) {
      // Hold user pending TOTP verification and switch UI on the same page
      setState(() {
        _pendingUser = authenticatedUser;
        _isOtpStage = true;
        _isLoading = false;
      });
      // Focus first OTP field automatically
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _otpFocusNodes[0].requestFocus();
        }
      });
      return;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _onVerifyOtp() async {
    final otpCode = _otpControllers.map((c) => c.text.trim()).join();

    if (otpCode.length != 6) {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'LOG-004',
          technicalDetails: 'Please enter all 6 digits of the Authenticator code.',
        ),
        3,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Verify TOTP code against Google Authenticator TOTP service
    final isValid = TotpService.instance.verifyTotp(otpCode);

    if (!mounted) return;

    if (isValid && _pendingUser != null) {
      // 2. Save user to local storage upon successful 2FA
      await StorageService.instance.setCurrentUser(_pendingUser!);

      if (!mounted) return;

      // 3. Transition to Dashboard
      Navigator.pushReplacement(
        context,
        PageTransitions.instantTransition(
          const DashboardScreen(fromLogin: true),
        ),
      );
    } else {
      ErrorManager.instance.showToastError(
        const ErrorStruct(
          code: 'LOG-005',
          technicalDetails: 'Invalid Authenticator OTP code. Please check your app.',
        ),
        3,
      );
      // Clear OTP fields for retry
      for (final controller in _otpControllers) {
        controller.clear();
      }
      _otpFocusNodes[0].requestFocus();
    }

    setState(() => _isLoading = false);
  }

  void _handleOtpInput(int index, String value) {
    // Support pasting full 6-digit OTP code directly
    if (value.length > 1) {
      final cleanDigits = value.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = cleanDigits[i];
        }
        _otpFocusNodes[5].requestFocus();
        return;
      }
    }

    if (value.isNotEmpty) {
      _otpControllers[index].text = value.substring(value.length - 1);
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_isOtpStage) {
            // Switch back to Login stage if on OTP screen
            setState(() {
              _isOtpStage = false;
              for (final c in _otpControllers) {
                c.clear();
              }
            });
            return;
          }

          await StorageService.instance.clearCurrentCompany();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageTransitions.fadeSlideUpTransition(const DomainScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Dynamic Background Layer
            Positioned.fill(
              child: Image.asset(
                ThemeManager.instance.getMainBG(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: Colors.black),
              ),
            ),

            // Foreground UI Layer
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Top Logo Mark
                    Image.asset(
                      ThemeManager.instance.getLogoMark(),
                      width: 42,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    // 3D Hero Graphic
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Image.asset(
                            ThemeManager.instance.getLoginMain(),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.security_rounded,
                                  color: Colors.white,
                                  size: 100,
                                ),
                          ),
                        ),
                      ),
                    ),

                    // Dynamic UI switching between Login and Authenticator OTP Stage
                    if (!_isOtpStage) _buildLoginStage() else _buildOtpStage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STAGE 1: LOGIN UI ---
  Widget _buildLoginStage() {
    return Column(
      key: const ValueKey('login_stage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Sign In to\nyour Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeManager.instance.getMatchColor(),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Enter your credentials',
            style: TextStyle(
              color: ThemeManager.instance.getGreyTransparent5(),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Username Field
        _buildTextField(
          controller: _usernameController,
          hintText: 'Enter username',
          icon: Icons.person_outline,
          obscureText: false,
        ),
        const SizedBox(height: 8),

        // Password Field with Visibility Toggle
        _buildTextField(
          controller: _passwordController,
          hintText: 'Enter password',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          isPassword: true,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 24),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.instance.getPrimaryColor(),
              foregroundColor: ThemeManager.instance.getContrastColor(),
              disabledBackgroundColor: ThemeManager.instance
                  .getPrimaryColor()
                  .withOpacity(0.5),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: ThemeManager.instance.getContrastColor(),
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Change Company Button
        Center(
          child: TextButton(
            onPressed: () async {
              await StorageService.instance.clearCurrentCompany();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                PageTransitions.fadeSlideUpTransition(const DomainScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
            ),
            child: Text(
              'Change Company',
              style: TextStyle(
                color: ThemeManager.instance.getMatchColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STAGE 2: GOOGLE AUTHENTICATOR TOTP UI ---
  Widget _buildOtpStage() {
    final isLight = ThemeManager.instance.isLightMode;

    return Column(
      key: const ValueKey('otp_stage'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title Header
        Text(
          'Check your\nAuthenticator',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ThemeManager.instance.getMatchColor(),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the OTP code you have on\nAuthenticator',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ThemeManager.instance.getGreyTransparent5(),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 28),

        // 6-Digit OTP Boxes Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 44,
              height: 56,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _otpControllers[index].text.isEmpty &&
                      index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF4F5F7)
                        : ThemeManager.instance.getGreyTransparent1(),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _otpFocusNodes[index].hasFocus
                          ? ThemeManager.instance.getPrimaryColor()
                          : (isLight
                              ? const Color(0xFFE2E4E8)
                              : ThemeManager.instance.getGreyTransparent3()),
                      width: _otpFocusNodes[index].hasFocus ? 1.5 : 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    enabled: !_isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => _handleOtpInput(index, val),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 32),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.instance.getPrimaryColor(),
              foregroundColor: ThemeManager.instance.getContrastColor(),
              disabledBackgroundColor: ThemeManager.instance
                  .getPrimaryColor()
                  .withOpacity(0.5),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: ThemeManager.instance.getContrastColor(),
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Need Help? Button
        Center(
          child: TextButton(
            onPressed: _launchHelpUrl,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
            ),
            child: Text(
              'Need Help?',
              style: TextStyle(
                color: ThemeManager.instance.getMatchColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
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
            icon,
            color: ThemeManager.instance.getGreyTransparent5(),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              enabled: !_isLoading,
              style: TextStyle(
                color: ThemeManager.instance.getMatchColor(),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: ThemeManager.instance.getGreyTransparent5(),
                  fontSize: 15,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                isDense: true,
              ),
            ),
          ),
          if (isPassword) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggleVisibility,
              child: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: ThemeManager.instance.getGreyTransparent5(),
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
