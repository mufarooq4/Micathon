import 'package:flutter/material.dart';

/// Tiny helpers for rendering family-member avatars without needing real
/// profile pictures. Same name → same color across the app.
class AvatarUtils {
  AvatarUtils._();

  static const List<Color> _palette = [
    Color(0xFF46654F),
    Color(0xFF974147),
    Color(0xFF3F51B5),
    Color(0xFF00502C),
    Color(0xFF7A4F00),
    Color(0xFF614D7B),
    Color(0xFF00606E),
  ];

  /// First letter of [name], uppercased. Falls back to '?'.
  static String initial(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  /// Stable color from the palette derived from [seed] (typically a uuid
  /// or full name). Same seed → same color forever.
  static Color colorFor(String seed) {
    if (seed.isEmpty) return _palette.first;
    var hash = 0;
    for (final code in seed.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }
}
