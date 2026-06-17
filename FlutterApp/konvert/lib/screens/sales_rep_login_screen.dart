// lib/screens/sales_rep_login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../managers/app_manager.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';

class SalesRepLoginScreen extends StatefulWidget {
  const SalesRepLoginScreen({super.key});

  @override
  State<SalesRepLoginScreen> createState() => _SalesRepLoginScreenState();
}

class _SalesRepLoginScreenState extends State<SalesRepLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    final storageService = Provider.of<StorageService>(context);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Exit app on back press
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Canvas Layer
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/loginBG.jpeg',
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
                          
                          // Dynamic Spacer pushing everything else cleanly to the bottom (Matches Domain Selection)
                          const Spacer(),

                          // 2. Heading Section (Positioned right above input boxes)
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Please login to continue',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 3. Input Form Fields Grouping (Matches Domain Field Design Pattern)
                          Column(
                            children: [
                              // Username Field Component Frame
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    fillColor: Colors.black,
                                    hintText: 'Username',
                                    hintStyle: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white.withOpacity(0.6), size: 22),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 14),
                              
                              // Password Field Component Frame
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.6), size: 20),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                                    fillColor: Colors.black,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword 
                                            ? Icons.visibility_outlined 
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                  onSubmitted: (_) => _handleLogin(appManager, storageService),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 42),

                          // 4. Primary CTA Button Grouping (Matches Connect Button Architecture)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoggingIn 
                                  ? null 
                                  : () => _handleLogin(appManager, storageService),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: Colors.white.withOpacity(0.25),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoggingIn
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 17, 
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(AppManager appManager, StorageService storageService) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      _showError('Please enter username');
      return;
    }
    
    if (password.isEmpty) {
      _showError('Please enter password');
      return;
    }
    
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final domain = appManager.selectedDomain;
      if (domain == null) {
        _showError('Domain not selected');
        setState(() {
          _isLoggingIn = false;
        });
        return;
      }
      
      final apiKey = domain.apiKey;
      
      final url = '${domain.url}/esalesmanAPI/checkuser.php';
      
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': username,
          'password': password,
          'apiKey': apiKey,
        },
      ).timeout(const Duration(seconds: 10));
      
      final responseString = response.body.trim();
      
      try {
        final jsonData = jsonDecode(responseString);
        final user = User.fromJson(jsonData).withLogin();
        
        await storageService.saveCurrentUser(user);
        appManager.currentUser = user;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
        
      } catch (e) {
        await _showErrorDialog(responseString);
      }
      
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showErrorDialog(String responseString) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Login Failed',
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
                  'Please check your credentials and try again.',
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}