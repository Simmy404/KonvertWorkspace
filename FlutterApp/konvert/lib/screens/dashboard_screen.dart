// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/app_manager.dart';
import '../services/storage_service.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppManager>(context);
    final user = appManager.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Get storage service from provider instead of creating new instance
              final storageService = Provider.of<StorageService>(context, listen: false);
              await storageService.logout();
              appManager.currentUser = null;
              
              // Use context.mounted (requires Flutter 3.10+)
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              user != null ? 'Welcome ${user.name}!' : 'Dashboard',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your dashboard is under construction',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}