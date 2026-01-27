import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/routing/routes.dart';

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
              context.pushNamed(AppRouteNames.settings);
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: theme.fg),
            onPressed: () {
              context.pushNamed(AppRouteNames.shop);
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: theme.fg),
            onPressed: () {
              context.pushNamed(AppRouteNames.palette);
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: theme.fg),
            onPressed: () {
              context.pushNamed(AppRouteNames.info);
            },
          ),
        ],
      ),
    );
  }
}
