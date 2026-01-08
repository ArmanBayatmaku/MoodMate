import 'package:flutter/material.dart';
import 'package:moodmate/models/home/mood.dart';
import 'package:moodmate/services/mood_service.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedDay,
  });

  final DateTime selectedDay;

  static const primaryBlue = Color(0xFF7F9BB8);
  static const textBlue = Color(0xFF6F8FB0);
  static const borderBlue = Color(0xFF8FB0D6);

  @override
  Widget build(BuildContext context) {
    final service = MoodService();

    const moods = [
      (MoodType.great, '😊', 'Great'),
      (MoodType.good, '🙂', 'Good'),
      (MoodType.okay, '😐', 'Okay'),
      (MoodType.down, '😔', 'Down'),
      (MoodType.difficult, '😞', 'Difficult'),
      (MoodType.stressed, '😰', 'Stressed'),
    ];

    return Column(
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
                border: Border.all(color: borderBlue.withOpacity(0.7)),
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
        GridView.builder(
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
            final (type, emoji, label) = moods[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await service.setMoodForDay(selectedDay, type);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: type.bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7DED3)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
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
          },
        ),
      ],
    );
  }
}
