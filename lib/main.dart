import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chain_reaction/screens/home_screen.dart';
import 'package:chain_reaction/providers/theme_provider.dart';
import 'package:chain_reaction/providers/player_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final ThemeProvider _themeProvider;
  late final PlayerProvider _playerProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _playerProvider = PlayerProvider();
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    _playerProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      themeProvider: _themeProvider,
      child: PlayerScope(
        playerProvider: _playerProvider,
        child: ListenableBuilder(
          listenable: Listenable.merge([_themeProvider, _playerProvider]),
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                brightness: _themeProvider.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
                scaffoldBackgroundColor: _themeProvider.bg,
                appBarTheme: AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: _themeProvider.isDarkMode
                        ? Brightness.light
                        : Brightness.dark,
                    statusBarBrightness: _themeProvider.isDarkMode
                        ? Brightness.dark
                        : Brightness.light, // For iOS
                  ),
                ),
                colorScheme: ColorScheme(
                  brightness: _themeProvider.isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                  primary: _themeProvider.fg,
                  onPrimary: _themeProvider.bg,
                  secondary: _themeProvider.subtitle,
                  onSecondary: _themeProvider.bg,
                  surface: _themeProvider.surface,
                  onSurface: _themeProvider.fg,
                  error: _themeProvider.currentTheme.red,
                  onError: Colors.white,
                ),
              ),
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}
