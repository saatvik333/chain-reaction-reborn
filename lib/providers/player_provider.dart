import 'package:flutter/material.dart';

/// Manages player data such as names.
class PlayerProvider extends ChangeNotifier {
  final Map<int, String> _playerNames = {};

  /// Get the name for a player (1-indexed).
  /// Returns "Player X" if no custom name is set.
  String getName(int index) {
    return _playerNames[index] ?? 'Player $index';
  }

  /// Update the name for a specific player (1-indexed).
  void updateName(int index, String newName) {
    if (newName.trim().isEmpty) {
      _playerNames.remove(index);
    } else {
      _playerNames[index] = newName.trim();
    }
    notifyListeners();
  }

  /// Reset all player names to default.
  void resetNames() {
    _playerNames.clear();
    notifyListeners();
  }
}

/// InheritedNotifier for PlayerProvider
class PlayerScope extends InheritedNotifier<PlayerProvider> {
  const PlayerScope({
    super.key,
    required PlayerProvider playerProvider,
    required super.child,
  }) : super(notifier: playerProvider);

  static PlayerProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlayerScope>();
    assert(scope != null, 'No PlayerScope found in context');
    return scope!.notifier!;
  }
}
