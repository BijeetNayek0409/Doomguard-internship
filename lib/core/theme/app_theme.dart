import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette (from Lovable "Unwind" design) ───────────────────────────────────
// Background:  HSL(240 30% 7%)  → #0D0D1A
// Card:        HSL(240 25% 11%) → #141422
// Primary:     HSL(258 89% 70%) → #8B6FF5 (soft violet)
// PrimaryGlow: HSL(270 95% 78%) → #C47AFC
// Secondary:   HSL(158 64% 60%) → #4DCFA0 (mint)
// Accent:      HSL(14 92% 70%)  → #F7835A  (coral)
// Streak:      HSL(32 100% 65%) → #FFA940
// Muted fg:    HSL(240 10% 65%) → #9B9BB5
// Border:      HSL(240 20% 18%) → #23233D

class DG {
  // Surfaces
  static const Color bg        = Color(0xFF0D0D1A);
  static const Color card      = Color(0xFF141422);
  static const Color muted     = Color(0xFF1E1E33);
  static const Color border    = Color(0xFF23233D);
  static const Color glassBg   = Color(0x8C141422);

  // Brand
  static const Color primary      = Color(0xFF8B6FF5);
  static const Color primaryGlow  = Color(0xFFC47AFC);
  static const Color secondary    = Color(0xFF4DCFA0); // mint
  static const Color accent       = Color(0xFFF7835A); // coral
  static const Color streak       = Color(0xFFFFA940); // amber
  static const Color destructive  = Color(0xFFEA5A6A);

  // Text
  static const Color fg           = Color(0xFFF2F2FA);
  static const Color mutedFg      = Color(0xFF9B9BB5);

  // Gradients
  static const LinearGradient violetGrad = LinearGradient(
    colors: [Color(0xFF8B6FF5), Color(0xFFC47AFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient mintGrad = LinearGradient(
    colors: [Color(0xFF4DCFA0), Color(0xFF4DCFCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient coralGrad = LinearGradient(
    colors: [Color(0xFFF7835A), Color(0xFFEA5A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient streakGrad = LinearGradient(
    colors: [Color(0xFFFFA940), Color(0xFFF7835A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Radius
  static const double r4  = 4;
  static const double r8  = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;
  static const double r32 = 32;
  static const double r36 = 36;
}

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: DG.bg,
      colorScheme: const ColorScheme.dark(
        primary: DG.primary,
        secondary: DG.secondary,
        surface: DG.card,
        error: DG.destructive,
        onPrimary: Colors.white,
        onSecondary: DG.bg,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: DG.fg,
        displayColor: DG.fg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: DG.fg,
      ),
      cardTheme: CardThemeData(
        color: DG.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DG.r24),
          side: const BorderSide(color: DG.border),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : DG.mutedFg),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? DG.secondary : DG.muted),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: DG.primary,
        inactiveTrackColor: DG.muted,
        thumbColor: DG.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DG.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DG.r16)),
          elevation: 0,
        ),
      ),
    );
  }
}