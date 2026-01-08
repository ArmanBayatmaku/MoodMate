import 'package:flutter/material.dart';

class AppColors {
  final String title;
  final Color bg;
  final Color card;
  final Color textDark;
  final Color textMuted;
  final Color accentBlue;
  final Color divider;

  const AppColors({
    required this.title,
    required this.bg,
    required this.card,
    required this.textDark,
    required this.textMuted,
    required this.accentBlue,
    required this.divider,
  });

  static const AppColors calmBlue = AppColors(
    title: 'Calm Blue',
    bg: Color(0xFFF6F1E9),
    card: Colors.white,
    textDark: Color(0xFF2E3B4E),
    textMuted: Color(0xFF8A96A8),
    accentBlue: Color(0xFF7F9BB8),
    divider: Color(0xFFE3DED6),
  );
  static const AppColors sageGarden = AppColors(
    title: 'Sage Garden',
    bg: Color(0xFFEFF0E9),
    card: Colors.white,
    textDark: Color(0xFF2E3B4E),
    textMuted: Color(0xFF8A96A8),
    accentBlue: Color(0xFF919C6A),
    divider: Color(0xFFA6B07E),
  );
  static const AppColors lavenderDreams = AppColors(
    title: 'Lavender Dreams',
    bg: Color(0xFFF7F5F9),
    card: Colors.white,
    textDark: Color(0xFF3E3A4F),
    textMuted: Color(0xFF8F8AA3),
    accentBlue: Color(0xFF8E82A9),
    divider: Color(0xFFE2DEEA),
  );
  static const AppColors warmSunset = AppColors(
    title: 'Warm Sunset',
    bg: Color(0xFFF7F1EA),
    card: Colors.white,
    textDark: Color(0xFF3A332C),
    textMuted: Color(0xFF9A8F83),
    accentBlue: Color(0xFFC8A77E),
    divider: Color(0xFFE6DDD2),
  );

  static const List<AppColors> all = [
    calmBlue,
    sageGarden,
    lavenderDreams,
    warmSunset,
  ];

  static AppColors? byTitle(String? title) {
    if (title == null) return null;
    for (final t in all) {
      if (t.title == title) return t;
    }
    return null;
  }
}
