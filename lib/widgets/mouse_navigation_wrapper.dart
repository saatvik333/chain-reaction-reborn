import 'package:flutter/material.dart';

/// A wrapper that detects mouse back/forward button clicks and navigates.
class MouseNavigationWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const MouseNavigationWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        // Mouse Button 4 (Back) -> Pop
        // Usually buttons 0=Left, 1=Right, 2=Middle.
        // Flutter PointerEvent buttons is a bitmask for Down events, but for Up events usually changedButton is relevant?
        // Actually, onPointerUp gives `event.buttons` as the buttons *remaining* down.
        // We probably want `onPointerDown` or compare `buttons`.
        //
        // However, standard mouse buttons:
        // kPrimaryButton = 1
        // kSecondaryButton = 2
        // kMiddleButton = 4
        // kBackButton = 8
        // kForwardButton = 16
        //
        // Let's use `onPointerDown`.
      },
      // Actually, let's use onPointerDown to capture the intention.
      onPointerDown: (event) {
        // 8 is Back button
        if (event.buttons == 8) {
          navigatorKey.currentState?.maybePop();
        }
        // 16 is Forward button - Not implemented as Navigator stack is one-way
      },
      child: child,
    );
  }
}
