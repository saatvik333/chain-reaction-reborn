import 'package:chain_reaction/core/services/haptic/haptic_service.dart';
import 'package:chain_reaction/features/game/data/repositories/game_repository_impl.dart';
import 'package:chain_reaction/features/game/domain/ai/ai_service.dart';
import 'package:chain_reaction/features/game/domain/logic/game_rules.dart';
import 'package:chain_reaction/features/game/domain/repositories/game_repository.dart';
import 'package:chain_reaction/features/game/domain/usecases/usecases.dart';
import 'package:chain_reaction/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Logic Providers ---

final gameRulesProvider = Provider<GameRules>((ref) {
  return const GameRules();
});

// --- Repository Providers ---

/// Provider for the GameRepository.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GameRepositoryImpl(prefs);
});

// --- Service Providers ---

/// Provider for the AIService.
final aiServiceProvider = Provider<AIService>((ref) {
  final rules = ref.watch(gameRulesProvider);
  return AIService(rules);
});

/// Provider for the HapticService.
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

// --- UseCase Providers ---

/// Provider for the InitializeGameUseCase.
final initializeGameUseCaseProvider = Provider<InitializeGameUseCase>((ref) {
  final rules = ref.watch(gameRulesProvider);
  return InitializeGameUseCase(rules);
});

/// Provider for the PlaceAtomUseCase.
final placeAtomUseCaseProvider = Provider<PlaceAtomUseCase>((ref) {
  final rules = ref.watch(gameRulesProvider);
  return PlaceAtomUseCase(rules);
});

/// Provider for the NextTurnUseCase.
final nextTurnUseCaseProvider = Provider<NextTurnUseCase>((ref) {
  return const NextTurnUseCase();
});

/// Provider for the CheckWinnerUseCase.
final checkWinnerUseCaseProvider = Provider<CheckWinnerUseCase>((ref) {
  return const CheckWinnerUseCase();
});
