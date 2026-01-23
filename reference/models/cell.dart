class Cell {
  final int x;
  final int y;
  final int capacity;
  final int atomCount;
  final String?
  ownerId; // Use ID to reference player, or nullable Player object? ID is safer for serialization.

  const Cell({
    required this.x,
    required this.y,
    required this.capacity,
    this.atomCount = 0,
    this.ownerId,
  });

  Cell copyWith({int? atomCount, String? ownerId, bool clearOwner = false}) {
    return Cell(
      x: x,
      y: y,
      capacity: capacity,
      atomCount: atomCount ?? this.atomCount,
      ownerId: clearOwner ? null : (ownerId ?? this.ownerId),
    );
  }
}
