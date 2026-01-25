import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../usecases/usecases.dart';
import 'rules_provider.dart';

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
