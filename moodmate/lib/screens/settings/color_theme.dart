import 'package:flutter/material.dart';
import 'package:moodmate/models/colors.dart';
import 'package:moodmate/controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  static const themes = [
    AppColors.calmBlue,
    AppColors.sageGarden,
    AppColors.lavenderDreams,
    AppColors.warmSunset,
  ];

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ThemeController>().colors;

    return Scaffold(
      backgroundColor: selected.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: selected.textDark,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: selected.accentBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      size: 34,
                      color: selected.accentBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                Text(
                  'Choose Your Theme',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: selected.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Pick a color that feels right for you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: selected.textMuted,
                  ),
                ),

                const SizedBox(height: 28),

                ...themes.map((c) => _ThemeCard(colors: c)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ThemeController>().colors;
    final isSelected = selected.title == colors.title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          context.read<ThemeController>().setTheme(colors);
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? colors.accentBlue
                  : colors.divider.withOpacity(0.7),
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          colors.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _subtitleFor(colors),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.bg.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _colorDot(colors.accentBlue),
                    const SizedBox(width: 10),
                    _colorDot(colors.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  String _subtitleFor(AppColors colors) {
    switch (colors.title) {
      case 'Calm Blue':
        return 'Your original peaceful design';
      case 'Sage Garden':
        return 'Tranquil green theme';
      case 'Lavender Dreams':
        return 'Gentle purple tones';
      case 'Warm Sunset':
        return 'Cozy warmth';
      default:
        return '';
    }
  }
}
