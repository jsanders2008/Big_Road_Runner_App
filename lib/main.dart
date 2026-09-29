import 'package:flutter/material.dart';

import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(BigroadrunnerApp(appState: appState));
}

class BigroadrunnerApp extends StatefulWidget {
  final AppState appState;

  const BigroadrunnerApp({
    super.key,
    required this.appState,
  });

  @override
  State<BigroadrunnerApp> createState() => _BigroadrunnerAppState();
}

class _BigroadrunnerAppState extends State<BigroadrunnerApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Big Road Runner App',
          debugShowCheckedModeBanner: false,
          themeMode: widget.appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Dark Theme (Default for Bigroadrunner Night Driving)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF101010),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFC107),
              brightness: Brightness.dark,
              primary: const Color(0xFFFFC107),
              secondary: const Color(0xFFFF8F00),
              surface: const Color(0xFF1A1A1A),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1A1A1A),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: const Color(0xFFFFC107).withValues(alpha: 0.15)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF222222),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
              ),
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),

          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF6F6F6),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB300),
              brightness: Brightness.light,
              primary: const Color(0xFFFF8F00),
              secondary: const Color(0xFFD50000),
              surface: Colors.white,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFEEEEEE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 1.5),
              ),
            ),
          ),

          home: _showSplash
              ? SplashScreen(onSplashComplete: _onSplashComplete)
              : MainNavigation(appState: widget.appState),
        );
      },
    );
  }
}
