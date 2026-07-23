// lib/screens/lock_screen.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../managers/security_manager.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'dashboard_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;
  String _userIdentity = '';

  @override
  void initState() {
    super.initState();
    _loadUserIdentity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  void _loadUserIdentity() {
    final user = StorageService.instance.getCurrentUser();
    if (user != null) {
      setState(() {
        _userIdentity = user.username.isNotEmpty ? user.username : user.name;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool didAuthenticate =
          await SecurityManager.instance.authenticateWithDeviceLock(
        reason: 'Please authenticate to unlock Konvert',
      );

      if (didAuthenticate && mounted) {
        _onUnlockSuccess();
      }
    } catch (e) {
      debugPrint('Device Lock Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _onUnlockSuccess() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeTransition(const DashboardScreen(fromLogin: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        final isLight = ThemeManager.instance.isLightMode;

        final Color bgStart = isLight
            ? const Color(0xFFF2F8FF)
            : const Color(0xFF020514);
        final Color bgEnd = isLight
            ? const Color(0xFFFFF4F6)
            : const Color(0xFF01020A);

        final Color logoPath = isLight ? const Color(0xFF0033FF) : Colors.white;
        final Color titleColor = isLight
            ? const Color(0xFF050505)
            : Colors.white;
        final Color subtextColor = isLight
            ? const Color(0xFF555555)
            : const Color(0xFF9E9E9E);
        final Color btnBg = isLight ? const Color(0xFF0033FF) : Colors.white;
        final Color btnText = isLight ? Colors.white : const Color(0xFF050505);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgStart, bgEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Left Branding Logo
                    Row(
                      children: [
                        Image.asset(
                          isLight
                              ? 'assets/branding/Logomark_Color.png'
                              : 'assets/branding/Logomark_White.png',
                          height: 36,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.lock_outline_rounded,
                            color: logoPath,
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // 3D Padlock Illustration
                    Center(
                      child: Image.asset(
                        ThemeManager.instance.getLockMain(),
                        height: 240,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.blue.shade50
                                : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 80,
                            color: btnBg,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Title & Description
                    Center(
                      child: Text(
                        'Unlock App',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: titleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Use your device lock to login as',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: subtextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        _userIdentity,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Unlock Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isAuthenticating ? null : _authenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnBg,
                          foregroundColor: btnText,
                          elevation: isLight ? 4 : 0,
                          shadowColor: isLight
                              ? const Color(0x400033FF)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                        child: _isAuthenticating
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: btnText,
                                ),
                              )
                            : Text(
                                'Unlock',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: btnText,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
