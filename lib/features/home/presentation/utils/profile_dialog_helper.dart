import 'package:chain_reaction/core/constants/app_dimensions.dart';
import 'package:chain_reaction/core/presentation/widgets/custom_popup.dart';
import 'package:chain_reaction/core/presentation/widgets/pill_button.dart';
import 'package:chain_reaction/core/theme/providers/theme_provider.dart';
import 'package:chain_reaction/features/auth/domain/entities/app_auth_state.dart';
import 'package:chain_reaction/features/auth/presentation/providers/auth_provider.dart';
import 'package:chain_reaction/features/home/presentation/providers/home_provider.dart';
import 'package:chain_reaction/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileDialogHelper {
  static void showProfilePopup(
    BuildContext context,
    WidgetRef ref,
    AppAuthStateAuthenticated authState,
  ) {
    final theme = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => CustomPopup(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.playerColors.first.withValues(alpha: 0.2),
                border: Border.all(
                  color: theme.playerColors.first.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child:
                    authState.avatarUrl != null &&
                        authState.avatarUrl!.isNotEmpty
                    ? Image.network(
                        authState.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildLargeInitialsAvatar(
                              theme,
                              _getInitials(
                                authState.displayName ?? authState.email,
                              ),
                            ),
                      )
                    : _buildLargeInitialsAvatar(
                        theme,
                        _getInitials(authState.displayName ?? authState.email),
                      ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Display Name
            if (authState.displayName != null &&
                authState.displayName!.isNotEmpty)
              Text(
                authState.displayName!,
                style: TextStyle(
                  color: theme.fg,
                  fontSize: AppDimensions.fontL,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: AppDimensions.paddingXS),

            // Email
            Text(
              authState.email,
              style: TextStyle(
                color: theme.subtitle,
                fontSize: AppDimensions.fontS,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Logout Button
            PillButton(
              text: 'Sign Out',
              type: PillButtonType.secondary,
              width: double.infinity,
              icon: Icon(Icons.logout_rounded, color: theme.fg, size: 18),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                // Reset home state to mode selection
                ref.read(homeProvider.notifier).reset();
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  // Navigate to home if not already there
                  context.goNamed(AppRouteNames.home);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLargeInitialsAvatar(ThemeState theme, String initials) {
    return Container(
      color: theme.playerColors.first.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.fg,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'[\s@]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
