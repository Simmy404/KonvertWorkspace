// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'master_sync_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _needsInitialSync = false;

  @override
  void initState() {
    super.initState();
    _checkInitialSync();
  }

  void _checkInitialSync() {
    final targets = StorageService.instance.getTargets();
    if (targets['month_target'] == '0' && targets['total_sales'] == '0') {
      _needsInitialSync = true;
      
      // Push instantly to Master Sync after the layout initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageTransitions.instantTransition(const MasterSyncScreen()),
          );
        }
      });
    }
  }

  void _triggerManualSync() {
    Navigator.push(
      context,
      PageTransitions.fadeTransition(const MasterSyncScreen()),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // SECURITY: Black out the screen for 1 frame to prevent any glimpses 
    // of the Dashboard UI if a master sync is required.
    if (_needsInitialSync) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final currentUser = StorageService.instance.getCurrentUser();
    final currentCompany = StorageService.instance.getCurrentCompany();
    final targets = StorageService.instance.getTargets();

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        ThemeManager.instance.getLogoMark(), 
                        width: 42,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      IconButton(
                        onPressed: _triggerManualSync,
                        icon: Icon(Icons.sync, color: ThemeManager.instance.getMatchColor()),
                        tooltip: 'Force Master Sync',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back,\n${currentUser?.name ?? 'User'}!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ThemeManager.instance.getMatchColor(),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Company: ${currentCompany?['name'] ?? 'Unknown'}\n'
                          'Target: ${targets['month_target']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ThemeManager.instance.getGreyTransparent5(),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}