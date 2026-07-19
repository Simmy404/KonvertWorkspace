import 'package:flutter/material.dart';
import 'managers/app_manager.dart';
import 'managers/error_manager.dart';
import 'managers/legal_manager.dart';
import 'managers/theme_manager.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 1. THIS IS THE CRITICAL LINE. 
  // It guarantees the engine is running before async platform channels are called.
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Boot up hardware storage first
  await StorageService.instance.init();
  
  // 3. Hydrate dependent managers
  await ThemeManager.instance.init();
  await LegalManager.instance.init();
  
  // 4. Finally, mount the UI
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konvert',
      debugShowCheckedModeBanner: false,
      navigatorKey: ErrorManager.instance.navigatorKey,
      scaffoldMessengerKey: ErrorManager.instance.messengerKey,
      theme: ThemeData.dark(), // We will link this to ThemeManager later if needed
      home: const SplashScreen(),
    );
  }
}