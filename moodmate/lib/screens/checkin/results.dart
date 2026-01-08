import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodmate/models/home/mood.dart';
import 'package:moodmate/services/mood_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.day,
    required this.mind,
    required this.energy,
    required this.thoughts,
  });

  final DateTime day;
  final String mind;
  final String energy;
  final String thoughts;

  static const bg = Color(0xFFF6F1E9);
  static const textDark = Color(0xFF2E3B4E);
  static const textMuted = Color(0xFF8A96A8);
  static const primary = Color(0xFF7F9BB8);

  static const border = Color(0xFFE3DED6);
  static const pillGrey = Color(0xFFF2F2F2);

  String _prettyMind(String v) {
    if (v.trim().isEmpty) return 'Skipped';
    if (v.startsWith('other:')) return v.replaceFirst('other:', '').trim();
    return switch (v) {
      'family' => 'Family and relationships',
      'health' => 'Health and wellness',
      'work' => 'Work or activities',
      'easy' => 'Just taking it easy',
      _ => v,
    };
  }

  String _prettyEnergy(String v) {
    if (v.trim().isEmpty) return 'Skipped';
    if (v.startsWith('other:')) return v.replaceFirst('other:', '').trim();
    return switch (v) {
      'low' => 'Very low energy',
      'medium' => 'Okay / steady',
      'high' => 'High energy',
      _ => v,
    };
  }

  String _prettyMood(MoodType m) {
    return switch (m) {
      MoodType.great => 'Great',
      MoodType.good => 'Good',
      MoodType.okay => 'Okay',
      MoodType.down => 'Down',
      MoodType.difficult => 'Difficult',
      MoodType.stressed => 'Stressed',
    };
  }

  @override
  Widget build(BuildContext context) {
    final moodService = MoodService();
    final dayStr = DateFormat('EEEE, MMMM d').format(day);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              child: Column(
                children: [
                  // Top icon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F2E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: Color(0xFF9FD3A8),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Thank you!',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your check-in has been recorded. I'm here every day.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Results card with mood + responses
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Mood",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: moodService.moodForDay(day),
                          builder: (context, snap) {
                            MoodType? mood;
                            if (snap.hasData && snap.data!.exists) {
                              final data = snap.data!.data();
                              mood = MoodTypeX.fromKey(
                                data?['mood']?.toString(),
                              );
                            }

                            final moodTitle = mood == null
                                ? 'Undefined'
                                : _prettyMood(mood);

                            final pillBg = mood == null
                                ? pillGrey
                                : mood.bgColor;

                            return _Pill(
                              title: moodTitle,
                              subtitle: dayStr,
                              background: pillBg,
                              textMuted: textMuted,
                              textDark: textDark,
                            );
                          },
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          "Your Responses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _SmallPill(text: _prettyMind(mind), pillGrey: pillGrey),
                        const SizedBox(height: 10),
                        _SmallPill(
                          text: _prettyEnergy(energy),
                          pillGrey: pillGrey,
                        ),

                        if (thoughts.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _SmallPill(text: thoughts.trim(), pillGrey: pillGrey),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Encouraging message panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD0D9E2)),
                    ),
                    child: Text(
                      "Remember, every day is a step forward. I'll be here tomorrow too. 💙",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primary,
                        height: 1.25,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom button
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text(
                        'Go Back Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.title,
    required this.subtitle,
    required this.background,
    required this.textDark,
    required this.textMuted,
  });

  final String title;
  final String subtitle;
  final Color background;
  final Color textDark;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.text,
    required this.pillGrey,
  });

  final String text;
  final Color pillGrey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: pillGrey,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E3B4E),
        ),
      ),
    );
  }
}
