import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_rules.dart';

final gameRulesProvider = Provider<GameRules>((ref) {
  return const GameRules();
});
