import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../features/game/presentation/providers/providers.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../../features/shop/presentation/screens/palette_screen.dart';
import '../../../../features/shop/presentation/screens/purchase_screen.dart';
import '../screens/info_screen.dart';

class HomeBottomBar extends ConsumerWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.fg),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: theme.fg),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PurchaseScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: theme.fg),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaletteScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: theme.fg),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
