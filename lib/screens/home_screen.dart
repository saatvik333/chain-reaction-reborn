import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/presentation/providers/providers.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_dimensions.dart';
import 'game_screen.dart';
import 'info_screen.dart';
import 'palette_screen.dart';
import 'purchase_screen.dart';
import 'settings_screen.dart';
import '../widgets/game_selector.dart';
import '../widgets/pill_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _playerCount = 2;
  final List<String> _gridSizes = [
    AppStrings.gridSizeXSmall,
    AppStrings.gridSizeSmall,
    AppStrings.gridSizeMedium,
    AppStrings.gridSizeLarge,
    AppStrings.gridSizeXLarge,
  ];
  int _gridSizeIndex = 2;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Column(
            children: [
              const Spacer(),
              // Central Orb Graphic
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    width: AppDimensions.orbSizeLarge,
                    height: AppDimensions.orbSizeLarge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.fg.withValues(alpha: 0.1),
                        width: AppDimensions.orbBorderWidth,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width:
                            80, // Keeping internal proportional sizes for now or move to dimen if generic
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.fg.withValues(alpha: 0.1),
                                  width: 4,
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.fg.withValues(alpha: 0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.fg.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.subtitle.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXXL),

              GameSelector(
                label: AppStrings.playersLabel,
                value: _playerCount.toString(),
                onPrevious: () {
                  if (_playerCount > 2) {
                    setState(() => _playerCount--);
                  }
                },
                onNext: () {
                  if (_playerCount < 8) {
                    setState(() => _playerCount++);
                  }
                },
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              GameSelector(
                label: AppStrings.gridSizeLabel,
                value: _gridSizes[_gridSizeIndex],
                onPrevious: () {
                  setState(() {
                    _gridSizeIndex =
                        (_gridSizeIndex - 1 + _gridSizes.length) %
                        _gridSizes.length;
                  });
                },
                onNext: () {
                  setState(() {
                    _gridSizeIndex = (_gridSizeIndex + 1) % _gridSizes.length;
                  });
                },
              ),

              const Spacer(flex: 2),

              PillButton(
                text: AppStrings.startGame,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        playerCount: _playerCount,
                        gridSize: _gridSizes[_gridSizeIndex],
                      ),
                    ),
                  );
                },
                width: double.infinity,
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: theme.fg),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: theme.fg),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PurchaseScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.palette, color: theme.fg),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PaletteScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.info, color: theme.fg),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InfoScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
