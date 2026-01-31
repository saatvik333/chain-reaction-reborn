import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provides a [SupabaseClient] instance for dependency injection.
///
/// This allows services to accept the client as a dependency rather than
/// accessing the global singleton directly, improving testability.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
