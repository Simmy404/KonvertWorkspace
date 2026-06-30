// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'managers/legal_manager.dart'; // Import your new manager
import 'managers/theme_manager.dart'; // Import your new manager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistent states cleanly before UI generation
  await LegalManager.instance.init();
  await ThemeManager.instance.init(); // Add this line
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konvert App',
      home: const SplashScreen(),
    );
  }
}