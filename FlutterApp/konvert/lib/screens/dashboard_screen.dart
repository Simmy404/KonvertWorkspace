// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../managers/theme_manager.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the active user data to demonstrate context availability
    final currentUser = StorageService.instance.getCurrentUser();
    final currentCompany = StorageService.instance.getCurrentCompany();

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
                  const SizedBox(height: 16),
                  Image.asset(
                    ThemeManager.instance.getLogoMark(), 
                    width: 42,
                    height: 32,
                    fit: BoxFit.contain,
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
                          'Connected to: ${currentCompany?['name'] ?? 'Unknown Company'}',
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