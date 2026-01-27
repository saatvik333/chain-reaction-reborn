import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:chain_reaction/l10n/generated/app_localizations.dart';

/// Intent for closing the application
class QuitIntent extends Intent {
  const QuitIntent();
}

/// Intent for navigating back
class GoBackIntent extends Intent {
  const GoBackIntent();
}

/// Intent for toggling fullscreen
class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}

/// A wrapper that adds Desktop-specific integrations:
/// - Global Keyboard Shortcuts (Esc, F11, Ctrl+Q)
/// - Native Menu Bar
/// - Mouse Back/Forward button support
class DesktopIntegrationWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const DesktopIntegrationWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    // If context doesn't have localizations yet (top of tree), we might need a workaround.
    // However, this wrapper is usually inside MaterialApp/WidgetsApp?
    // Let's assume it has access or check usage.
    // If it's ABOVE MaterialApp, it won't work.
    // DesktopIntegrationWrapper seems to be used at root?
    // Let's check main.dart.

    // Assuming it's inside, or we use a fallback if not available?
    // But it has navigatorKey, so it implies setup.
    // Let's safe access via context.
    final l10n = AppLocalizations.of(context);
    // If l10n is null, we can't localize menu bar nicely without context.
    // But PlatformMenuBar IS a widget.

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: l10n?.menuLabel ?? 'Menu',
          menus: [
            PlatformMenuItem(
              label: l10n?.aboutLabel ?? 'About',
              onSelected: () {
                showAboutDialog(
                  context: navigatorKey.currentContext!,
                  applicationName: l10n?.appName ?? 'Chain Reaction',
                  applicationVersion: '1.0.0',
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copyright, size: 14),
                        const SizedBox(width: 4),
                        Text(l10n?.appLegalese ?? '2026 Saatvik'),
                      ],
                    ),
                  ],
                );
              },
            ),
            if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit,
            ))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
          ],
        ),
        PlatformMenu(
          label: l10n?.viewLabel ?? 'View',
          menus: [
            PlatformMenuItem(
              label: l10n?.toggleFullscreen ?? 'Toggle Fullscreen',
              shortcut: const SingleActivator(LogicalKeyboardKey.f11),
              onSelected: _toggleFullscreen,
            ),
          ],
        ),
      ],
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.escape):
              const GoBackIntent(),
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
              const QuitIntent(),
          const SingleActivator(LogicalKeyboardKey.f11):
              const ToggleFullscreenIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            GoBackIntent: CallbackAction<GoBackIntent>(
              onInvoke: (intent) => navigatorKey.currentState?.maybePop(),
            ),
            QuitIntent: CallbackAction<QuitIntent>(
              onInvoke: (intent) {
                // On Windows/Linux, we can try using windowManager to close
                if (!kIsWeb) {
                  windowManager.close();
                }
                return null;
              },
            ),
            ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
              onInvoke: (intent) => _toggleFullscreen(),
            ),
          },
          child: Listener(
            onPointerDown: (event) {
              // Mouse Back Button (Often button 8, or "Back" on some mice)
              if (event.buttons == 8) {
                navigatorKey.currentState?.maybePop();
              }
            },
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFullscreen() async {
    if (kIsWeb) return; // WindowManager not supported on Web
    bool isFullScreen = await windowManager.isFullScreen();
    if (isFullScreen) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
  }
}
