import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color card;
  final Color bottomBar;
  final Color topBar;
  final Color topBarTitle;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardTitle;
  final Color border;
  final Color accent;
  final Color counterCircle;
  final Color resetIcon;
  final Color surahCircle;
  final Color drawerHeart;
  final Color blessing;

  const AppPalette({
    required this.background,
    required this.card,
    required this.bottomBar,
    required this.topBar,
    required this.topBarTitle,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardTitle,
    required this.border,
    required this.accent,
    required this.counterCircle,
    required this.resetIcon,
    required this.surahCircle,
    required this.drawerHeart,
    required this.blessing,
  });

  static const light = AppPalette(
    background: Color(0xFFF6F8F7),
    card: Color(0xFFFFFFFF),
    bottomBar: Color(0xFFFFFFFF),
    topBar: Color(0xFF11A6F9),
    topBarTitle: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF94A3B8),
    cardTitle: Color(0xFF11A6F9),
    border: Color(0xFFE2E8F0),
    accent: Color(0xFF11A6F9),
    counterCircle: Color(0xFF11A6F9),
    resetIcon: Colors.black,
    surahCircle: Color(0xFFE8F5FE),
    drawerHeart: Color(0x33FFFFFF),
    blessing: Color(0xB3FFFFFF),
  );

  static const dark = AppPalette(
    background: Color(0xFF0E1621),
    card: Color(0xFF182331),
    bottomBar: Color(0xFF121C28),
    topBar: Color(0xFF0F4C7A),
    topBarTitle: Color(0xFFF2F7FB),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF8A97A6),
    cardTitle: Color(0xFFE6EDF3),
    border: Color(0xFF2A3646),
    accent: Color(0xFF6CC4FF),
    counterCircle: Color(0xFF1B9BF0),
    resetIcon: Colors.white,
    surahCircle: Color(0xFF1E3A55),
    drawerHeart: Color(0xFF2B6E9E),
    blessing: Color(0xFFA9C7DE),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      card: l(card, other.card),
      bottomBar: l(bottomBar, other.bottomBar),
      topBar: l(topBar, other.topBar),
      topBarTitle: l(topBarTitle, other.topBarTitle),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      cardTitle: l(cardTitle, other.cardTitle),
      border: l(border, other.border),
      accent: l(accent, other.accent),
      counterCircle: l(counterCircle, other.counterCircle),
      resetIcon: l(resetIcon, other.resetIcon),
      surahCircle: l(surahCircle, other.surahCircle),
      drawerHeart: l(drawerHeart, other.drawerHeart),
      blessing: l(blessing, other.blessing),
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
