import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_themes.dart';
import 'presentation/auth/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Intelligence Platform',
      theme: AppThemes.darkTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark obsidian mode
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
