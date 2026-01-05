import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1E9);
    const primaryBlue = Color(0xFF7F9BB8);
    const textBlue = Color(0xFF6F8FB0);
    const borderBlue = Color(0xFF8FB0D6);
    const divider = Color(0xFFD9D0C6);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Good evening, Friend',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E3B4E),
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your mood every day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textBlue.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Mood Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Calendar Card
                  _CardShell(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _IconPillButton(
                              icon: Icons.chevron_left,
                              onTap: () {},
                            ),
                            const Spacer(),
                            const Text(
                              'January 2026',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E3B4E),
                              ),
                            ),
                            const Spacer(),
                            _IconPillButton(
                              icon: Icons.chevron_right,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: divider,
                        ),
                        const SizedBox(height: 12),
                        const _CalendarGrid(
                          borderBlue: borderBlue,
                          textBlue: textBlue,
                          selectedDay: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mood Selector Card
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderBlue.withOpacity(0.7),
                                ),
                              ),
                              child: Icon(
                                Icons.sentiment_satisfied_alt,
                                size: 18,
                                color: textBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Select your mood for today:',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: textBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _MoodGrid(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Daily Check-in Card
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderBlue.withOpacity(0.7),
                                ),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: textBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Check-in',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Share more about how you're feeling",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: textBlue.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue.withOpacity(0.85),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Start Today's Check-in",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Match the soft card look in the screenshot
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DED3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconPillButton extends StatelessWidget {
  const _IconPillButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7DED3)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6F8FB0)),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.borderBlue,
    required this.textBlue,
    required this.selectedDay,
  });

  final Color borderBlue;
  final Color textBlue;
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Hardcoded January 2026 layout (as shown in the screenshot)
    // Jan 2026 starts on Thu. The screenshot shows days 1-31 with blanks before.
    final cells = <int?>[
      null,
      null,
      null,
      null,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdays
                .map(
                  (d) => SizedBox(
                    width: 40,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: textBlue.withOpacity(0.75),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final day = cells[index];
            if (day == null) {
              return const SizedBox.shrink();
            }

            final isSelected = day == selectedDay;

            return Center(
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: isSelected
                      ? Border.all(color: borderBlue, width: 2)
                      : null,
                ),
                child: Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3B4E),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MoodGrid extends StatelessWidget {
  const _MoodGrid();

  @override
  Widget build(BuildContext context) {
    // These colors are chosen to match the soft pastel tiles in the screenshot.
    const moods = [
      _MoodTileData('😊', 'Great', Color(0xFFE7F2E7)),
      _MoodTileData('🙂', 'Good', Color(0xFFE3F1FB)),
      _MoodTileData('😐', 'Okay', Color(0xFFF7F0D8)),
      _MoodTileData('😔', 'Down', Color(0xFFF6E6D9)),
      _MoodTileData('😞', 'Difficult', Color(0xFFF4DDE2)),
      _MoodTileData('😰', 'Stressed', Color(0xFFE9F1FF)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moods.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        final m = moods[i];
        return _MoodTile(
          emoji: m.emoji,
          label: m.label,
          background: m.background,
          onTap: () {},
        );
      },
    );
  }
}

class _MoodTileData {
  const _MoodTileData(this.emoji, this.label, this.background);
  final String emoji;
  final String label;
  final Color background;
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.emoji,
    required this.label,
    required this.background,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7DED3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E3B4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
