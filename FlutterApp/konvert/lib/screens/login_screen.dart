// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import '../utils/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // State to track password visibility

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ErrorManager.instance.showToastError(
          const ErrorStruct(code: 'LOG-001', technicalDetails: 'Could not launch URL'),
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
        const ErrorStruct(code: 'LOG-003', technicalDetails: 'Fields cannot be empty.'),
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
      // 2. Save user to local storage
      await StorageService.instance.setCurrentUser(authenticatedUser);
      
      if (!mounted) return;
      
      // 3. Instantly transition to Dashboard
      Navigator.pushReplacement(
        context,
        PageTransitions.instantTransition(const DashboardScreen()), 
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
          // Dynamic Background Layer
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Colors.black),
            ),
          ),
          
          // Foreground UI Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), 
                  
                  // MATCHED: Exact logo dimensions
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
                  
                  // Expanded pushes content to dynamically fit space without scrolling
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Image.asset(
                          ThemeManager.instance.getLoginMain(), 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Headers
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
                        letterSpacing: -0.5
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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: -0.3
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Help Button
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
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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