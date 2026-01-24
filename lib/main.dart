import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chain_reaction/features/home/presentation/screens/home_screen.dart';
import 'package:chain_reaction/features/game/presentation/providers/providers.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';

import 'package:chain_reaction/core/theme/custom_transitions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    _setHighRefreshRate();
  }

  Future<void> _setHighRefreshRate() async {
    if (Platform.isAndroid) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (e) {
        // Fail silently, platform might not support it
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Chain Reaction Reborn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: themeState.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: themeState.bg,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeState.isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: themeState.isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
        ),
        colorScheme: ColorScheme(
          brightness: themeState.isDarkMode
              ? Brightness.dark
              : Brightness.light,
          primary: themeState.fg,
          onPrimary: themeState.bg,
          secondary: themeState.subtitle,
          onSecondary: themeState.bg,
          surface: themeState.surface,
          onSurface: themeState.fg,
          error: themeState.currentTheme.red,
          onError: Colors.white,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FluidFadePageTransitionsBuilder(),
            TargetPlatform.iOS: FluidFadePageTransitionsBuilder(),
            TargetPlatform.macOS: FluidFadePageTransitionsBuilder(),
            TargetPlatform.windows: FluidFadePageTransitionsBuilder(),
            TargetPlatform.linux: FluidFadePageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
