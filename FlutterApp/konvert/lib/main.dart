import 'dart:ui';
import 'package:flutter/material.dart';
import 'managers/app_manager.dart';
import 'managers/error_manager.dart';
import 'managers/legal_manager.dart';
import 'managers/theme_manager.dart';
import 'models/error_struct.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 1. THIS IS THE CRITICAL LINE. 
  // It guarantees the engine is running before async platform channels are called.
  WidgetsFlutterBinding.ensureInitialized();

  // Global Framework Error Handler -> Debug Console
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorManager.instance.logErrorToConsole(
      'FRAMEWORK',
      ErrorStruct(
        code: 'FLT-001',
        technicalDetails: details.exceptionAsString(),
      ),
      details.stack,
    );
  };

  // Global Uncaught Async Error Handler -> Debug Console
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    ErrorManager.instance.logErrorToConsole(
      'UNCAUGHT',
      ErrorStruct(
        code: 'ASYNC-001',
        technicalDetails: error.toString(),
      ),
      stack,
    );
    return true;
  };

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
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Konvert',
          debugShowCheckedModeBanner: false,
          navigatorKey: ErrorManager.instance.navigatorKey,
          scaffoldMessengerKey: ErrorManager.instance.messengerKey,
          theme: ThemeManager.instance.isLightMode ? ThemeData.light() : ThemeData.dark(),
          home: const SplashScreen(),
        );
      },
    );
  }
}