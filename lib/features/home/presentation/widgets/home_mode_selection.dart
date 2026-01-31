import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import 'package:chain_reaction/routing/routes.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/game_selector.dart';
import '../../../../core/presentation/widgets/pill_button.dart';
import '../providers/home_provider.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';

class HomeModeSelection extends ConsumerWidget {
  const HomeModeSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey('ModeSelection'),
      children: [
        GameSelector(
          label: l10n.gameModeLabel,
          value: switch (state.selectedMode) {
            GameMode.localMultiplayer => l10n.localMultiplayer,
            GameMode.vsComputer => l10n.vsComputer,
            GameMode.online => l10n.onlineMultiplayer,
          },

          onPrevious: () => notifier.cycleMode(),
          onNext: () => notifier.cycleMode(),
        ),

        const Spacer(),
        PillButton(
          text: l10n.next,
          onTap: () {
            if (state.selectedMode == GameMode.online) {
              final authState = ref.read(authProvider);
              switch (authState) {
                case AppAuthStateAuthenticated():
                  // Go to inline configuration instead of separate lobby screen
                  notifier.setStep(HomeStep.configuration);
                case _:
                  context.pushNamed(AppRouteNames.auth);
              }
            } else {
              notifier.setStep(HomeStep.configuration);
            }
          },
          width: double.infinity,
        ),
      ],
    );
  }
}
