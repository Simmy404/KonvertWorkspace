// lib/screens/tos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../managers/legal_manager.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'theme_selection_screen.dart'; // Make sure to create this file

class TosScreen extends StatefulWidget {
  const TosScreen({super.key});

  @override
  State<TosScreen> createState() => _TosScreenState();
}

class _TosScreenState extends State<TosScreen> {
  String _htmlContent = '';
  bool _isLoading = true;
  
  // LOGIC ADDED: State variables for scrolling
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTosContent();
    
    // LOGIC ADDED: Attach the scroll listener
    _scrollController.addListener(_onScroll);
  }

  // LOGIC ADDED: Detect when user reaches the bottom
  void _onScroll() {
    if (!_scrollController.hasClients || _hasScrolledToBottom) return;

    if (_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 20)) {
      setState(() {
        _hasScrolledToBottom = true;
      });
    }
  }

  Future<void> _loadTosContent() async {
    try {
      final String content = await rootBundle.loadString('assets/legal/tos.txt');
      
      if (!mounted) return;
      setState(() {
        _htmlContent = content;
        _isLoading = false;
      });

      // LOGIC ADDED: Auto-enable if content is too short to scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _scrollController.position.maxScrollExtent <= 0) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'TOS-001', 
          technicalDetails: 'Failed to load Terms of Service document: $e'
        ),
        4,
      );
    }
  }

  // LOGIC ADDED: Save to local storage and route
  Future<void> _acceptAndContinue() async {
    await LegalManager.instance.setTermsAccepted(true);
    await StorageService.instance.setBool('hasCheckedTos', true);
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeSlideUpTransition(const ThemeSelectionScreen()), 
    );
  }

  @override
  void dispose() {
    // LOGIC ADDED: Cleanup
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Stack(
        children: [
          // Background Image Layer
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
                  const SizedBox(height: 10),
                  
                  Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: ThemeManager.instance.getPrimaryColor(),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gradient Text Container
                  Expanded(
                    flex: 12,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ThemeManager.instance.getGreyTransparent3(), 
                            ThemeManager.instance.getGreyTransparent4(), 
                          ],
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : SingleChildScrollView(
                              controller: _scrollController, // LOGIC ADDED: Attached controller
                              padding: const EdgeInsets.all(20.0),
                              child: Html(
                                data: _htmlContent,
                                style: {
                                  "body": Style(
                                    color: ThemeManager.instance.getGreyTransparent5(),
                                    fontSize: FontSize(12.0),
                                    lineHeight: LineHeight(1.2),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  "h1": Style(
                                    color: ThemeManager.instance.getGreyTransparent5(),
                                    fontSize: FontSize(18.0),
                                    fontWeight: FontWeight.bold,
                                    margin: Margins.only(top: 0.0, bottom: 10.0),
                                  ),
                                  "h2": Style(
                                    color: ThemeManager.instance.getGreyTransparent5(),
                                    fontSize: FontSize(14.0),
                                    fontWeight: FontWeight.bold,
                                    margin: Margins.only(top: 16.0, bottom: 8.0),
                                  ),
                                  "p": Style(
                                    margin: Margins.only(bottom: 16.0),
                                  ),
                                  "ul": Style(
                                    margin: Margins.only(bottom: 12.0),
                                    padding: HtmlPaddings.only(left: 20.0),
                                  ),
                                  "li": Style(
                                    margin: Margins.only(bottom: 5.0),
                                  ),
                                },
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64, 
                    child: ElevatedButton(
                      // LOGIC ADDED: Dynamic function binding based on scroll state
                      onPressed: _hasScrolledToBottom ? _acceptAndContinue : null, 
                      style: ElevatedButton.styleFrom(
                        // LOGIC ADDED: Active colors when scrolled to bottom
                        backgroundColor: ThemeManager.instance.getPrimaryColor(),
                        foregroundColor: ThemeManager.instance.getContrastColor(),
                        disabledBackgroundColor: ThemeManager.instance.getGreyTransparent1(),
                        disabledForegroundColor: ThemeManager.instance.getGreyTransparent2(),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        // LOGIC ADDED: Dynamic text based on scroll state
                        _hasScrolledToBottom ? 'Continue' : 'Scroll to Accept',
                        style: const TextStyle(
                          fontSize: 18, 
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
    ),
    );
  }
}