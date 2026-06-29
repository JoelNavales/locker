import 'package:flutter/painting.dart';

import '../models/locker_model.dart';

abstract final class AppColors {
  const AppColors._();

  /// Cream page background.
  static const Color cream = Color(0xFFFFFBEF);

  /// Ink — used for borders, text, and the hard shadow.
  static const Color ink = Color(0xFF111111);

  /// White surface.
  static const Color surface = Color(0xFFFFFFFF);

  // Priority colors.
  static const Color priorityHigh = Color(0xFFFF4D6D);
  static const Color priorityMedium = Color(0xFFFFC93C);
  static const Color priorityLow = Color(0xFF22C55E);

  // Accents.
  static const Color blue = Color(0xFF3A86FF);
  static const Color violet = Color(0xFF9B5DE5);

  /// Text/icon color used on top of dark or saturated surfaces.
  static const Color onInk = Color(0xFFFFFFFF);

  /// Fill color for a locker of the given priority.
  static Color forPriority(Priority priority) => switch (priority) {
    Priority.high => priorityHigh,
    Priority.medium => priorityMedium,
    Priority.low => priorityLow,
  };

  /// Readable text/icon color to use on top of a [forPriority] fill.
  /// Medium (yellow) needs dark ink; the others are dark enough for white.
  static Color onPriority(Priority priority) =>
      priority == Priority.medium ? ink : onInk;
}
