// lib/screens/master_sync_screen.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../services/api_service.dart';
import '../utils/page_transitions.dart';
import 'dashboard_screen.dart';

class MasterSyncScreen extends StatefulWidget {
  const MasterSyncScreen({super.key});

  @override
  State<MasterSyncScreen> createState() => _MasterSyncScreenState();
}

class _MasterSyncScreenState extends State<MasterSyncScreen> {
  // UI checklist state trackers
  bool _syncingTourPlan = false;
  bool _syncingProducts = false;
  bool _syncingChemists = false;
  bool _syncingDoctors = false;
  
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    // Delay start slightly to allow the transition animation to finish smoothly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMasterSync();
    });
  }

  Future<void> _startMasterSync() async {
    try {
      // 1. Sync Bricks (Tour Plan)
      setState(() => _syncingTourPlan = true);
      final brickSuccess = await ApiService.instance.syncBricks();
      if (!brickSuccess) throw 'Failed to sync Tour Plan.';

      // 2. Sync Products
      setState(() => _syncingProducts = true);
      final prodSuccess = await ApiService.instance.syncProducts();
      if (!prodSuccess) throw 'Failed to sync Products.';

      // 3. Sync Customers (Chemists & Doctors)
      setState(() {
        _syncingChemists = true;
        _syncingDoctors = true; // Based on the API, these share the same endpoint
      });
      final custSuccess = await ApiService.instance.syncCustomers();
      if (!custSuccess) throw 'Failed to sync Customers.';

      // 4. Sync Target (Silent in UI text, but necessary data)
      final targetSuccess = await ApiService.instance.syncTarget();
      if (!targetSuccess) throw 'Failed to sync Targets.';

      // Done
      setState(() => _isComplete = true);
      
      // Briefly show completed state before routing
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(const DashboardScreen()), 
      );

    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'SYNC-001', technicalDetails: e.toString()),
        5,
      );
      // Even if it fails, fallback to dashboard so user isn't permanently trapped
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageTransitions.fadeTransition(const DashboardScreen()), 
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      ThemeManager.instance.getLogoMark(), 
                      width: 42,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // 3D Sphere Element
                Image.asset(
                  ThemeManager.instance.getSyncMain(),
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                
                // Headings
                Text(
                  'Syncing',
                  style: TextStyle(
                    color: ThemeManager.instance.getMatchColor(),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please Wait',
                  style: TextStyle(
                    color: ThemeManager.instance.getMatchColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Dynamic Status List
                _buildStatusText('Syncing Tour Plan...', _syncingTourPlan),
                const SizedBox(height: 8),
                _buildStatusText('Syncing Products...', _syncingProducts),
                const SizedBox(height: 8),
                _buildStatusText('Syncing Chemists...', _syncingChemists),
                const SizedBox(height: 8),
                _buildStatusText('Syncing Doctors...', _syncingDoctors),
                
                const SizedBox(height: 36),
                
                // Loader
                _isComplete 
                  ? Icon(Icons.check_circle_outline, color: ThemeManager.instance.getPrimaryColor(), size: 32)
                  : CircularProgressIndicator(
                      color: ThemeManager.instance.getPrimaryColor(),
                      strokeWidth: 3,
                    ),
                
                const SizedBox(height: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Visual helper to highlight which items are actively syncing or finished
  Widget _buildStatusText(String text, bool isActive) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        // Turns stark MatchColor when active, remains faded grey when waiting
        color: isActive ? ThemeManager.instance.getMatchColor() : ThemeManager.instance.getGreyTransparent5(),
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        letterSpacing: -0.3,
      ),
      child: Text(text),
    );
  }
}