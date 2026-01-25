import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../../settings/domain/providers/settings_providers.dart';

/// Provider for the GameRepository.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GameRepositoryImpl(prefs);
});
