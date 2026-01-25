import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/haptic_service.dart';
import 'rules_provider.dart';

/// Provider for the AIService.
final aiServiceProvider = Provider<AIService>((ref) {
  final rules = ref.watch(gameRulesProvider);
  return AIService(rules);
});

/// Provider for the HapticService.
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
