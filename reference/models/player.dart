import 'dart:ui';

class Player {
  final String id;
  final String name;
  final Color color;
  final bool isAI;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.isAI = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
