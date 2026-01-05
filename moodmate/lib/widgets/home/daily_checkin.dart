import 'package:flutter/material.dart';

class DailyCheckInCard extends StatelessWidget {
  const DailyCheckInCard({
    super.key,
    required this.completed,
    required this.onTap,
  });

  final bool completed;
  final VoidCallback? onTap;

  static const primaryBlue = Color(0xFF7F9BB8);
  static const textBlue = Color(0xFF6F8FB0);
  static const borderBlue = Color(0xFF8FB0D6);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                border: Border.all(color: borderBlue.withOpacity(0.7)),
              ),
              child: Icon(
                completed ? Icons.check_circle_outline : Icons.auto_awesome,
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
                    completed ? 'Daily Check-in completed' : 'Daily Check-in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    completed
                        ? "You've already checked in today"
                        : "Share more about how you're feeling",
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
            onPressed: completed ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: completed
                  ? primaryBlue.withOpacity(0.35)
                  : primaryBlue.withOpacity(0.85),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              completed ? "Come back tomorrow" : "Start Today's Check-in",
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
