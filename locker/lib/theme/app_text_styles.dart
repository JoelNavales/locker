import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  const AppTextStyles._();

  /// Huge stacked wordmark (e.g. the onboarding "LOCKER").
  static TextStyle display(Color color) => GoogleFonts.poppins(
        fontSize: 52,
        height: 0.9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: color,
      );

  /// Section heading, e.g. "MY LOCKERS".
  static TextStyle heading(Color color) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color,
      );

  /// Locker / card title.
  static TextStyle title(Color color) => GoogleFonts.poppins(
        fontSize: 14,
        height: 1.05,
        fontWeight: FontWeight.w800,
        color: color,
      );

  /// Uppercase, tracked label used above inputs and on buttons.
  static TextStyle label(Color color) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: color,
      );

  /// Small uppercase label for pills and nav items.
  static TextStyle caption(Color color) => GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: color,
      );

  /// Body / meta text.
  static TextStyle body(Color color) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
