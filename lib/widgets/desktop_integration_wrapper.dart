import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:chain_reaction/core/constants/app_strings.dart';

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
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: AppStrings.menuLabel,
          menus: [
            PlatformMenuItem(
              label: AppStrings.aboutLabel,
              onSelected: () {
                showAboutDialog(
                  context: navigatorKey.currentContext!,
                  applicationName: AppStrings.appName,
                  applicationVersion: '1.0.0',
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copyright, size: 14),
                        const SizedBox(width: 4),
                        const Text(AppStrings.appLegalese),
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
          label: AppStrings.viewLabel,
          menus: [
            PlatformMenuItem(
              label: AppStrings.toggleFullscreen,
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
